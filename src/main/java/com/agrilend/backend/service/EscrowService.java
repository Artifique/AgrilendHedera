package com.agrilend.backend.service;

import com.agrilend.backend.entity.Order;
import com.agrilend.backend.entity.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

@Service
public class EscrowService {

    private static final Logger logger = LoggerFactory.getLogger(EscrowService.class);
    private static final BigDecimal PLATFORM_FEE_PERCENTAGE = new BigDecimal("0.02"); // 2% fee

    @Autowired
    private HederaService hederaService;

    @Value("${hedera.escrow.account.id:}") // Changed from contract.id to account.id for clarity
    private String escrowAccountId;

    @Value("${hedera.operator.account-id:}")
    private String operatorAccountId;

    public String initiateEscrow(Order order) {
        try {
            logger.info("Initiation du séquestre pour la commande: {}", order.getId());

            User buyerUser = order.getBuyer().getUser();
            String buyerAccountId = buyerUser.getHederaAccountId();
            String buyerPrivateKey = buyerUser.getHederaPrivateKey();
            logger.info("Buyer Account ID: {}", buyerAccountId);

            if (buyerAccountId == null || buyerAccountId.isEmpty() || buyerPrivateKey == null || buyerPrivateKey.isEmpty()) {
                throw new IllegalStateException("L'acheteur n'a pas de compte ou de clé privée Hedera configuré");
            }

            BigDecimal amountInHbar = order.getTotalAmount();
            logger.info("Amount in HBAR: {}", amountInHbar);

            BigDecimal buyerBalance = hederaService.getAccountBalance(buyerAccountId);
            logger.info("Buyer Balance: {}", buyerBalance);

            if (buyerBalance.compareTo(amountInHbar) < 0) {
                throw new IllegalStateException("Solde insuffisant sur le compte Hedera de l'acheteur");
            }

            if (escrowAccountId == null || escrowAccountId.isEmpty()) {
                String simulatedTxId = "simulated_tx_" + System.currentTimeMillis();
                logger.warn("Mode simulation - Escrow initiated: {} for order: {}", simulatedTxId, order.getId());
                return simulatedTxId;
            }

            logger.info("Attempting HBAR transfer from {} to {} for amount {}", buyerAccountId, escrowAccountId, amountInHbar);
            String transactionId = hederaService.transferHbar(
                buyerAccountId,
                buyerPrivateKey,
                escrowAccountId,
                amountInHbar
            );
            logger.info("HBAR transfer completed. Transaction ID: {}", transactionId);

            logger.info("Séquestre initié avec succès pour la commande: {} (TX: {})", order.getId(), transactionId);
            return transactionId;

        } catch (Exception e) {
            logger.error("Failed to initiate escrow for order: {}", order.getId(), e);
            throw new RuntimeException("Failed to initiate escrow: " + e.getMessage(), e);
        }
    }

    public String releaseEscrow(Order order) {
        try {
            logger.info("Releasing escrow for order: {}", order.getId());

            User farmerUser = order.getOffer().getFarmer().getUser();
            String farmerAccountId = farmerUser.getHederaAccountId();

            if (farmerAccountId == null || farmerAccountId.isEmpty()) {
                throw new IllegalStateException("L'agriculteur n'a pas de compte Hedera configuré");
            }

            BigDecimal totalAmount = order.getTotalAmount();
            BigDecimal platformFee = totalAmount.multiply(PLATFORM_FEE_PERCENTAGE);
            BigDecimal farmerAmount = totalAmount.subtract(platformFee);

            if (escrowAccountId == null || escrowAccountId.isEmpty()) {
                String simulatedTxId = "simulated_tx_" + System.currentTimeMillis();
                logger.warn("Mode simulation - Escrow released: {} for order: {}", simulatedTxId, order.getId());
                return simulatedTxId;
            }

            String transactionId = hederaService.releaseFromEscrow(
                escrowAccountId,
                farmerAccountId,
                farmerAmount,
                operatorAccountId, // Platform fees go to the operator account
                platformFee
            );

            logger.info("Escrow released successfully for order: {} (TX: {})", order.getId(), transactionId);
            return transactionId;

        } catch (Exception e) {
            logger.error("Failed to release escrow for order: {}", order.getId(), e);
            throw new RuntimeException("Failed to release escrow: " + e.getMessage(), e);
        }
    }
}