package com.agrilend.backend.service;

import com.agrilend.backend.dto.tokenization.TokenDistributionDto;
import com.agrilend.backend.entity.*;
import com.agrilend.backend.entity.enums.ProductUnit;
import com.agrilend.backend.entity.enums.TransactionType;
import com.agrilend.backend.repository.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Service de tokenisation des récoltes selon le processus défini dans les cahiers des charges
 */
@Service
@Transactional
public class TokenizationService {

    private static final Logger logger = LoggerFactory.getLogger(TokenizationService.class);

    @Autowired
    private WarehouseReceiptRepository warehouseReceiptRepository;

    @Autowired
    private HarvestTokenRepository harvestTokenRepository;

    @Autowired
    private TransactionRepository transactionRepository;

    // @Autowired // Commented out to force simulation mode for HederaService
    private HederaService hederaService = null; // Force null to activate simulation mode

    @Value("${hedera.treasury.account-id:0.0.6825338}")
    private String treasuryAccountId;

    /**
     * Étape 0: L'agriculteur livre sa récolte à l'entrepôt
     */
    public WarehouseReceipt createWarehouseReceipt(Farmer farmer, Product product, String batchNumber,
                                                   BigDecimal grossWeight, BigDecimal netWeight,
                                                   ProductUnit weightUnit, String storageLocation, String qualityGrade) {
        
        // Vérifier que le numéro de lot n'existe pas déjà
        if (warehouseReceiptRepository.existsByBatchNumber(batchNumber)) {
            throw new IllegalArgumentException("Le numéro de lot " + batchNumber + " existe déjà");
        }

        WarehouseReceipt receipt = new WarehouseReceipt();
        receipt.setFarmer(farmer);
        receipt.setProduct(product);
        receipt.setBatchNumber(batchNumber);
        receipt.setGrossWeight(grossWeight);
        receipt.setNetWeight(netWeight);
        receipt.setWeightUnit(weightUnit);
        receipt.setStorageLocation(storageLocation);
        receipt.setQualityGrade(qualityGrade);
        receipt.setDeliveryDate(LocalDateTime.now());

        // Générer le hash du reçu pour l'audit
        String receiptHash = generateReceiptHash(receipt);
        receipt.setReceiptHash(receiptHash);

        WarehouseReceipt savedReceipt = warehouseReceiptRepository.save(receipt);

        logger.info("Reçu d'entrepôt créé: {} pour l'agriculteur: {}", 
                   batchNumber, farmer.getUser().getEmail());

        return savedReceipt;
    }

    /**
     * Étape 1: Vérification/approbation par le responsable qualité et l'auditeur
     */
    public void validateWarehouseReceipt(Long receiptId, User validator, String inspectionReport) {
        WarehouseReceipt receipt = warehouseReceiptRepository.findById(receiptId)
            .orElseThrow(() -> new RuntimeException("Reçu d'entrepôt non trouvé"));

        if (receipt.getValidated()) {
            throw new IllegalStateException("Ce reçu a déjà été validé");
        }

        receipt.setValidated(true);
        receipt.setValidatedAt(LocalDateTime.now());
        receipt.setValidatedBy(validator);
        receipt.setInspectionReport(inspectionReport);

        // Signature de l'auditeur (simulation)
        receipt.setAuditorSignature("AUDITOR_SIGNATURE_" + System.currentTimeMillis());

        warehouseReceiptRepository.save(receipt);

        logger.info("Reçu d'entrepôt validé: {} par: {}", 
                   receipt.getBatchNumber(), validator.getEmail());
    }

    /**
     * Étape 2: Préparation de la frappe en tant que transaction programmée
     */
    public String prepareScheduledTokenMint(Long receiptId) {
        WarehouseReceipt receipt = warehouseReceiptRepository.findById(receiptId)
            .orElseThrow(() -> new RuntimeException("Reçu d'entrepôt non trouvé"));

        if (!receipt.getValidated()) {
            throw new IllegalStateException("Le reçu doit être validé avant la tokenisation");
        }

        if (receipt.getTokensMinted()) {
            throw new IllegalStateException("Ce reçu a déjà été tokenisé");
        }

        try {
            // Créer d'abord le token si nécessaire
            HarvestToken harvestToken = getOrCreateHarvestToken(receipt);

            // Calculer la quantité à frapper (1 token = 1 kg)
            BigDecimal tokensToMint = receipt.getNetWeight();

            // Créer la transaction programmée sur Hedera
            String scheduleId = hederaService.createScheduledTokenMint(
                harvestToken.getHederaTokenId(),
                tokensToMint,
                receipt.getBatchNumber(),
                receipt.getReceiptHash()
            );

            receipt.setScheduledTransactionId(scheduleId);
            warehouseReceiptRepository.save(receipt);

            // Enregistrer la transaction
            Transaction transaction = new Transaction();
            transaction.setWarehouseReceipt(receipt);
            transaction.setHarvestToken(harvestToken);
            transaction.setType(TransactionType.SCHEDULED_TRANSACTION);
            transaction.setAmount(tokensToMint);
            transaction.setScheduleId(scheduleId);
            transaction.setStatus(Transaction.TransactionStatus.PENDING);
            transactionRepository.save(transaction);

            logger.info("Transaction programmée créée: {} pour le lot: {}", 
                       scheduleId, receipt.getBatchNumber());

            return scheduleId;

        } catch (Exception e) {
            logger.error("Erreur lors de la création de la transaction programmée", e);
            throw new RuntimeException("Impossible de créer la transaction programmée", e);
        }
    }

    /**
     * Étape 3: Signature du calendrier par l'auditeur/administrateur
     */
    public void signScheduledTransaction(String scheduleId, User auditor) {
        try {
            // Signer la transaction programmée sur Hedera
            String transactionId = hederaService.signScheduledTransaction(scheduleId, auditor);

            // Mettre à jour le reçu
            WarehouseReceipt receipt = warehouseReceiptRepository.findByScheduledTransactionId(scheduleId)
                .orElseThrow(() -> new RuntimeException("Reçu non trouvé pour le schedule ID: " + scheduleId));

            receipt.setTokenMintTransactionId(transactionId);
            receipt.setTokensMinted(true);
            warehouseReceiptRepository.save(receipt);

            // Mettre à jour la transaction
            Transaction transaction = transactionRepository.findByScheduleId(scheduleId)
                .orElseThrow(() -> new RuntimeException("Transaction non trouvée"));

            transaction.setHederaTransactionId(transactionId);
            transaction.setStatus(Transaction.TransactionStatus.SUCCESS);
            transactionRepository.save(transaction);

            logger.info("Transaction programmée signée et exécutée: {} par: {}", 
                       scheduleId, auditor.getEmail());

        } catch (Exception e) {
            logger.error("Erreur lors de la signature de la transaction programmée", e);
            throw new RuntimeException("Impossible de signer la transaction programmée", e);
        }
    }

    /**
     * Étape 4: Distribution des tokens aux agriculteurs/investisseurs
     */
    public void distributeTokens(Long receiptId, List<TokenDistributionDto> distributions) {
        WarehouseReceipt receipt = warehouseReceiptRepository.findById(receiptId)
            .orElseThrow(() -> new RuntimeException("Reçu d'entrepôt non trouvé"));

        if (!receipt.getTokensMinted()) {
            throw new IllegalStateException("Les tokens n'ont pas encore été créés");
        }

        HarvestToken harvestToken = harvestTokenRepository.findByWarehouseReceipt(receipt)
            .orElseThrow(() -> new RuntimeException("Token non trouvé"));

        try {
            for (TokenDistributionDto distribution : distributions) {
                String transactionId = hederaService.transferTokens(
                    harvestToken.getHederaTokenId(),
                    treasuryAccountId,
                    distribution.getRecipientAccountId(),
                    distribution.getAmount()
                );

                // Enregistrer la transaction de distribution
                Transaction transaction = new Transaction();
                transaction.setHarvestToken(harvestToken);
                transaction.setType(TransactionType.FARMER_PAYMENT);
                transaction.setAmount(distribution.getAmount());
                transaction.setFromAccount(treasuryAccountId);
                transaction.setToAccount(distribution.getRecipientAccountId());
                transaction.setHederaTransactionId(transactionId);
                transaction.setStatus(Transaction.TransactionStatus.SUCCESS);
                transactionRepository.save(transaction);

                logger.info("Tokens distribués: {} tokens vers {}", 
                           distribution.getAmount(), distribution.getRecipientAccountId());
            }

        } catch (Exception e) {
            logger.error("Erreur lors de la distribution des tokens", e);
            throw new RuntimeException("Impossible de distribuer les tokens", e);
        }
    }

    /**
     * Étape 5: Rachat des tokens
     */
    public void redeemTokens(String tokenId, String buyerAccountId, BigDecimal amount) {
        HarvestToken harvestToken = harvestTokenRepository.findByHederaTokenId(tokenId)
            .orElseThrow(() -> new RuntimeException("Token non trouvé"));

        try {
            // Transférer les tokens du buyer vers la trésorerie
            String transactionId = hederaService.transferTokens(
                tokenId,
                buyerAccountId,
                treasuryAccountId,
                amount
            );

            // Enregistrer la transaction de rachat
            Transaction transaction = new Transaction();
            transaction.setHarvestToken(harvestToken);
            transaction.setType(TransactionType.TOKEN_BURN);
            transaction.setAmount(amount);
            transaction.setFromAccount(buyerAccountId);
            transaction.setToAccount(treasuryAccountId);
            transaction.setHederaTransactionId(transactionId);
            transaction.setStatus(Transaction.TransactionStatus.SUCCESS);
            transactionRepository.save(transaction);

            logger.info("Tokens rachetés: {} tokens de {}", amount, buyerAccountId);

        } catch (Exception e) {
            logger.error("Erreur lors du rachat des tokens", e);
            throw new RuntimeException("Impossible de racheter les tokens", e);
        }
    }

    /**
     * Obtient ou crée un token de récolte pour un reçu d'entrepôt
     */
    private HarvestToken getOrCreateHarvestToken(WarehouseReceipt receipt) {
        Optional<HarvestToken> existingToken = harvestTokenRepository.findByWarehouseReceipt(receipt);
        
        if (existingToken.isPresent()) {
            return existingToken.get();
        }

        // Créer un nouveau token
        String tokenName = receipt.getProduct().getName() + "_" + receipt.getBatchNumber();
        String tokenSymbol = receipt.getProduct().getName().substring(0, 3).toUpperCase() + 
                           receipt.getBatchNumber().substring(0, 3);
        
        // Supply maximale basée sur le poids net (1 token = 1 kg)
        BigDecimal maxSupply = receipt.getNetWeight();

        try {
            String hederaTokenId = hederaService.createFungibleToken(
                tokenName,
                tokenSymbol,
                maxSupply,
                treasuryAccountId
            );

            HarvestToken harvestToken = new HarvestToken();
            harvestToken.setWarehouseReceipt(receipt);
            harvestToken.setHederaTokenId(hederaTokenId);
            harvestToken.setTokenName(tokenName);
            harvestToken.setTokenSymbol(tokenSymbol);
            harvestToken.setMaxSupply(maxSupply);
            harvestToken.setTotalSupply(BigDecimal.ZERO);
            harvestToken.setTreasuryAccountId(treasuryAccountId);

            return harvestTokenRepository.save(harvestToken);

        } catch (Exception e) {
            logger.error("Erreur lors de la création du token", e);
            throw new RuntimeException("Impossible de créer le token", e);
        }
    }

    /**
     * Génère un hash pour le reçu d'entrepôt
     */
    private String generateReceiptHash(WarehouseReceipt receipt) {
        String data = receipt.getBatchNumber() + 
                     receipt.getNetWeight().toString() + 
                     receipt.getDeliveryDate().toString() +
                     receipt.getFarmer().getUser().getId().toString();
        
        return "HASH_" + Math.abs(data.hashCode());
    }

    /**
     * Obtient un reçu d'entrepôt par son ID
     */
    public WarehouseReceipt getWarehouseReceiptById(Long receiptId) {
        return warehouseReceiptRepository.findById(receiptId)
            .orElseThrow(() -> new RuntimeException("Reçu d'entrepôt non trouvé avec l'ID: " + receiptId));
    }
}