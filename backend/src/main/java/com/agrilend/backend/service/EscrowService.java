package com.agrilend.backend.service;

import com.agrilend.backend.entity.Order;
import com.agrilend.backend.entity.User;
import com.hedera.hashgraph.sdk.PrivateKey;
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
            // buyerPrivateKey is no longer needed here as the transaction will be signed client-side
            logger.info("Buyer Account ID: {}", buyerAccountId);

            if (buyerAccountId == null || buyerAccountId.isEmpty()) {
                throw new IllegalStateException("L'acheteur n'a pas de compte Hedera configuré");
            }

            BigDecimal amountInHbar = order.getTotalAmount();
            logger.info("Amount in HBAR: {}", amountInHbar);

            BigDecimal buyerBalance = hederaService.getAccountBalance(buyerAccountId);
            logger.info("Buyer Balance: {}", buyerBalance);

            if (buyerBalance.compareTo(amountInHbar) < 0) {
                throw new IllegalStateException("Solde insuffisant sur le compte Hedera de l'acheteur");
            }

            if (escrowAccountId == null || escrowAccountId.isEmpty()) {
                // In simulation mode, we would still return a placeholder for the unsigned transaction
                String simulatedUnsignedTx = "simulated_unsigned_tx_" + System.currentTimeMillis();
                logger.warn("Mode simulation - Escrow initiated: {} for order: {}", simulatedUnsignedTx, order.getId());
                return simulatedUnsignedTx;
            }

            logger.info("Preparing unsigned HBAR transfer from {} to {} for amount {}", buyerAccountId, escrowAccountId, amountInHbar);
            String unsignedTransaction = hederaService.prepareHbarTransferTransaction(
                buyerAccountId,
                escrowAccountId,
                amountInHbar
            );
            logger.info("Unsigned HBAR transfer prepared.");

            logger.info("Séquestre initié avec succès pour la commande: {} (Unsigned TX: {})", order.getId(), unsignedTransaction);
            return unsignedTransaction; // Return the unsigned transaction for client-side signing

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

            // Transfer farmer's amount
            String farmerTxId = hederaService.transferHbar(
                escrowAccountId,
                hederaService.getOperatorKey(), // Assuming operator key controls escrow for now
                farmerAccountId,
                farmerAmount
            );
            logger.info("Farmer amount transferred. Transaction ID: {}", farmerTxId);

            // Transfer platform fee
            String feeTxId = hederaService.transferHbar(
                escrowAccountId,
                hederaService.getOperatorKey(), // Assuming operator key controls escrow for now
                operatorAccountId,
                platformFee
            );
            logger.info("Platform fee transferred. Transaction ID: {}", feeTxId);

            logger.info("Escrow released successfully for order: {} (Farmer TX: {}, Fee TX: {})", order.getId(), farmerTxId, feeTxId);
            return farmerTxId; // Return one of the transaction IDs, or a combined one if needed

        } catch (Exception e) {
            logger.error("Failed to release escrow for order: {}", order.getId(), e);
            throw new RuntimeException("Failed to release escrow: " + e.getMessage(), e);
        }
    }
}