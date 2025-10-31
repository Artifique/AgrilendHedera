package com.agrilend.backend.service;

import com.agrilend.backend.entity.Buyer;
import com.agrilend.backend.entity.HbarDeposit;
import com.agrilend.backend.entity.User;
import com.agrilend.backend.entity.enums.DepositStatus;
import com.agrilend.backend.repository.BuyerRepository;
import com.agrilend.backend.repository.HbarDepositRepository;
import com.hedera.hashgraph.sdk.AccountId;
import com.hedera.hashgraph.sdk.ContractId;
import com.hedera.hashgraph.sdk.ContractFunctionParameters;
import com.hedera.hashgraph.sdk.ContractFunctionResult;
import com.hedera.hashgraph.sdk.Hbar;
import com.hedera.hashgraph.sdk.TransactionId;
import com.hedera.hashgraph.sdk.TransactionReceipt;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.concurrent.TimeoutException;

@Service
@Transactional
public class HbarDepositService {

    private static final Logger logger = LoggerFactory.getLogger(HbarDepositService.class);

    @Autowired
    private HbarDepositRepository hbarDepositRepository;

    @Autowired
    private BuyerRepository buyerRepository;

    @Autowired
    private HederaService hederaService;

    @Autowired
    private HederaSmartContractService smartContractService;

    @Value("${hedera.harvest-vault.contract-id:}")
    private String harvestVaultContractId;

    /**
     * Enregistre un dépôt HBAR et initie sa vérification.
     * @param buyerId L'ID de l'acheteur.
     * @param hbarAmount Le montant de HBAR déposé.
     * @param hederaTransactionId L'ID de la transaction Hedera.
     * @return L'entité HbarDeposit sauvegardée.
     */
    public HbarDeposit createAndVerifyDeposit(Long buyerId, BigDecimal hbarAmount, String hederaTransactionId) {
        Buyer buyer = buyerRepository.findById(buyerId)
                .orElseThrow(() -> new RuntimeException("Acheteur non trouvé avec l'ID: " + buyerId));

        if (harvestVaultContractId.isEmpty()) {
            throw new IllegalStateException("L'ID du contrat HarvestVault n'est pas configuré.");
        }

        HbarDeposit deposit = new HbarDeposit();
        deposit.setBuyer(buyer);
        deposit.setHbarAmount(hbarAmount);
        deposit.setHederaTransactionId(hederaTransactionId);
        deposit.setVaultContractId(harvestVaultContractId);
        deposit.setStatus(DepositStatus.PENDING_VERIFICATION);
        deposit = hbarDepositRepository.save(deposit);

        // Vérification immédiate (peut être asynchrone dans une implémentation réelle)
        verifyHbarDeposit(deposit);

        return deposit;
    }

    /**
     * Vérifie un dépôt HBAR sur le réseau Hedera.
     * Cette méthode devrait idéalement être appelée de manière asynchrone ou via un scheduler.
     * @param deposit L'entité HbarDeposit à vérifier.
     */
    public void verifyHbarDeposit(HbarDeposit deposit) {
        try {
            // 1. Récupérer le reçu de la transaction
            TransactionId txId = TransactionId.fromString(deposit.getHederaTransactionId());
            TransactionReceipt receipt = txId.getReceipt(hederaService.getClient());

            if (receipt.status.toString().equals("SUCCESS")) {
                // 2. Vérifier que le montant déposé dans le contrat correspond à ce que l'acheteur a envoyé
                // Appeler la fonction 'deposits' du contrat pour l'acheteur
                // Convertir l'ID de compte Hedera en adresse EVM pour le mapping Solidity
                String buyerHederaEVMAddress = AccountId.fromString(deposit.getBuyer().getUser().getHederaAccountId()).toSolidityAddress();

                ContractFunctionParameters params = new ContractFunctionParameters()
                        .addAddress(buyerHederaEVMAddress);

                ContractFunctionResult result = smartContractService.callContractViewFunction(
                        harvestVaultContractId, "deposits", params);
                
                // Le contrat stocke en tinybars, donc le résultat est un BigInteger représentant les tinybars.
                BigDecimal depositedAmountInContractTinybars = new BigDecimal(result.getUint256(0));
                BigDecimal expectedAmountInTinybars = deposit.getHbarAmount().multiply(new BigDecimal("100000000"));

                // Vérifier que le montant déposé dans le contrat est au moins égal au montant attendu
                // (Il pourrait y avoir des dépôts multiples, donc >= est plus sûr que ==)
                if (depositedAmountInContractTinybars.compareTo(expectedAmountInTinybars) >= 0) {
                    deposit.setStatus(DepositStatus.VERIFIED);
                    deposit.setVerificationDate(LocalDateTime.now());
                    logger.info("Dépôt HBAR {} vérifié avec succès pour l'acheteur {}", deposit.getId(), deposit.getBuyer().getId());
                } else {
                    deposit.setStatus(DepositStatus.FAILED_VERIFICATION);
                    logger.warn("Dépôt HBAR {} échoué: Montant dans le contrat ({}) ne correspond pas au montant attendu ({}).", 
                                deposit.getId(), depositedAmountInContractTinybars, expectedAmountInTinybars);
                }
            } else {
                deposit.setStatus(DepositStatus.FAILED_VERIFICATION);
                logger.warn("Dépôt HBAR {} échoué: Statut de transaction Hedera non SUCCESS ({}).", deposit.getId(), receipt.status);
            }
        } catch (Exception e) {
            deposit.setStatus(DepositStatus.FAILED_VERIFICATION);
            logger.error("Erreur lors de la vérification du dépôt HBAR {} : {}", deposit.getId(), e.getMessage(), e);
        } finally {
            hbarDepositRepository.save(deposit);
        }
    }

    // Méthode pour récupérer un dépôt par son ID
    public HbarDeposit getDepositById(Long depositId) {
        return hbarDepositRepository.findById(depositId)
                .orElseThrow(() -> new RuntimeException("Dépôt HBAR non trouvé avec l'ID: " + depositId));
    }
}
