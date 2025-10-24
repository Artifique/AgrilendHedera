package com.agrilend.backend.service;

import com.agrilend.backend.entity.User;
import com.hedera.hashgraph.sdk.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.math.BigDecimal;

/**
 * Service d'intégration avec Hedera Hashgraph pour la tokenisation des récoltes
 */
@Service
public class HederaService {

    private static final Logger logger = LoggerFactory.getLogger(HederaService.class);

    @Value("${hedera.network:testnet}")
    private String network;

    @Value("${hedera.operator.account-id:}")
    private String operatorAccountId;

    @Value("${hedera.operator.private-key:}")
    private String operatorPrivateKey;

    @Value("${hedera.treasury.account-id:}")
    private String treasuryAccountId;

    private Client client;
    private AccountId operatorId;
    private PrivateKey operatorKey;

    @PostConstruct
    public void initializeClient() {
        try {
            // Configuration du réseau Hedera
            if ("mainnet".equalsIgnoreCase(network)) {
                client = Client.forMainnet();
            } else {
                client = Client.forTestnet();
            }

            // Configuration du compte opérateur
            if (operatorAccountId != null && !operatorAccountId.isEmpty() &&
                    operatorPrivateKey != null && !operatorPrivateKey.isEmpty()) {

                operatorId = AccountId.fromString(operatorAccountId);
                operatorKey = PrivateKey.fromString(operatorPrivateKey);
                client.setOperator(operatorId, operatorKey);

                logger.info("Client Hedera initialisé avec succès sur le réseau: {}", network);
            } else {
                logger.warn("Configuration Hedera incomplète - mode simulation activé");
            }

        } catch (Exception e) {
            logger.error("Erreur lors de l'initialisation du client Hedera", e);
        }
    }

    /**
     * Crée un token fongible pour représenter une récolte
     */
    public String createFungibleToken(String tokenName, String tokenSymbol, 
                                     BigDecimal maxSupply, String treasuryAccountId) {
        try {
            if (client == null || operatorId == null) {
                // Mode simulation
                String simulatedTokenId = "0.0." + (System.currentTimeMillis() % 1000000);
                logger.info("Mode simulation - Token créé: {} ({})", simulatedTokenId, tokenSymbol);
                return simulatedTokenId;
            }

            AccountId treasury = AccountId.fromString(treasuryAccountId);

            logger.info("Creating fungible token with: Name={}, Symbol={}, MaxSupply={}, Treasury={}",
                tokenName, tokenSymbol, maxSupply, treasuryAccountId);

            TokenCreateTransaction tokenCreateTx = new TokenCreateTransaction()
                    .setTokenName(tokenName)
                    .setTokenSymbol(tokenSymbol)
                    .setDecimals(0)
                    .setInitialSupply(0)
                    .setMaxSupply(maxSupply.longValue())
                    .setTreasuryAccountId(treasury)
                    .setSupplyType(TokenSupplyType.FINITE)
                    .setSupplyKey(operatorKey)
                    .setAdminKey(operatorKey)
                    .setFreezeDefault(false)
                    .setTokenMemo("Harvest token for " + tokenName);

            TransactionResponse response = tokenCreateTx.execute(client);
            TransactionReceipt receipt = response.getReceipt(client);
            TokenId tokenId = receipt.tokenId;

            logger.info("Token fongible créé: {} ({})", tokenId, tokenSymbol);
            return tokenId.toString();

        } catch (Exception e) {
            logger.error("Erreur lors de la création du token fongible", e);
            throw new RuntimeException("Impossible de créer le token fongible", e);
        }
    }

    /**
     * Crée une transaction programmée pour le minting de tokens
     */
    public String createScheduledTokenMint(String tokenId, BigDecimal amount, 
                                          String batchNumber, String receiptHash) {
        try {
            if (client == null || operatorId == null) {
                // Mode simulation
                String simulatedScheduleId = "0.0." + (System.currentTimeMillis() % 1000000);
                logger.info("Mode simulation - Transaction programmée créée: {} pour le batch: {}", 
                           simulatedScheduleId, batchNumber);
                return simulatedScheduleId;
            }

            TokenId token = TokenId.fromString(tokenId);

            TokenMintTransaction mintTx = new TokenMintTransaction()
                    .setTokenId(token)
                    .setAmount(amount.longValue())
                    .setTransactionMemo("Mint for batch: " + batchNumber);

            ScheduleCreateTransaction scheduleTx = new ScheduleCreateTransaction()
                    .setScheduledTransaction(mintTx)
                    .setScheduleMemo("Scheduled mint for batch: " + batchNumber + ", hash: " + receiptHash)
                    .setAdminKey(operatorKey);

            TransactionResponse response = scheduleTx.execute(client);
            TransactionReceipt receipt = response.getReceipt(client);
            ScheduleId scheduleId = receipt.scheduleId;

            logger.info("Transaction programmée créée: {} pour le batch: {}", scheduleId, batchNumber);
            return scheduleId.toString();

        } catch (Exception e) {
            logger.error("Erreur lors de la création de la transaction programmée", e);
            throw new RuntimeException("Impossible de créer la transaction programmée", e);
        }
    }

    /**
     * Signe une transaction programmée
     */
    public String signScheduledTransaction(String scheduleId, User auditor) {
        try {
            if (client == null || operatorId == null) {
                // Mode simulation
                String simulatedTxId = "0.0." + (System.currentTimeMillis() % 1000000) + "@" + 
                                     (System.currentTimeMillis() / 1000);
                logger.info("Mode simulation - Transaction programmée signée: {} par: {}", 
                           scheduleId, auditor.getEmail());
                return simulatedTxId;
            }

            ScheduleId schedule = ScheduleId.fromString(scheduleId);

            ScheduleSignTransaction signTx = new ScheduleSignTransaction()
                    .setScheduleId(schedule);

            TransactionResponse response = signTx.execute(client);
            String transactionId = response.transactionId.toString();

            logger.info("Transaction programmée signée et exécutée: {} par: {}", 
                       scheduleId, auditor.getEmail());
            return transactionId;

        } catch (Exception e) {
            logger.error("Erreur lors de la signature de la transaction programmée", e);
            throw new RuntimeException("Impossible de signer la transaction programmée", e);
        }
    }

    /**
     * Transfère des tokens entre comptes
     */
    public String transferTokens(String tokenId, String fromAccountId, 
                                String toAccountId, BigDecimal amount) {
        try {
            if (client == null || operatorId == null) {
                // Mode simulation
                String simulatedTxId = "0.0." + (System.currentTimeMillis() % 1000000) + "@" + 
                                     (System.currentTimeMillis() / 1000);
                logger.info("Mode simulation - Tokens transférés: {} {} de {} vers {}", 
                           amount, tokenId, fromAccountId, toAccountId);
                return simulatedTxId;
            }

            TokenId token = TokenId.fromString(tokenId);
            AccountId fromAccount = AccountId.fromString(fromAccountId);
            AccountId toAccount = AccountId.fromString(toAccountId);

            TransferTransaction transferTx = new TransferTransaction()
                    .addTokenTransfer(token, fromAccount, -amount.longValue())
                    .addTokenTransfer(token, toAccount, amount.longValue());

            TransactionResponse response = transferTx.execute(client);
            String transactionId = response.transactionId.toString();

            logger.info("Tokens transférés: {} {} de {} vers {}", 
                       amount, tokenId, fromAccountId, toAccountId);
            return transactionId;

        } catch (Exception e) {
            logger.error("Erreur lors du transfert de tokens", e);
            throw new RuntimeException("Impossible de transférer les tokens", e);
        }
    }

    /**
     * Crée un nouveau compte Hedera pour un utilisateur
     */
    public HederaAccountInfo createAccount(String userEmail) {
        try {
            if (client == null || operatorId == null) {
                // Mode simulation
                String simulatedAccountId = "0.0." + (System.currentTimeMillis() % 1000000);
                String simulatedPrivateKey = "302e020100300506032b657004220420" + 
                                           String.format("%032x", System.currentTimeMillis());
                String simulatedPublicKey = "302a300506032b6570032100" + 
                                          String.format("%032x", System.currentTimeMillis() + 1);
                
                logger.info("Mode simulation - Compte créé: {} pour: {}", simulatedAccountId, userEmail);
                return new HederaAccountInfo(simulatedAccountId, simulatedPrivateKey, simulatedPublicKey);
            }

            PrivateKey newAccountPrivateKey = PrivateKey.generateED25519();
            PublicKey newAccountPublicKey = newAccountPrivateKey.getPublicKey();

            TransactionResponse response = new AccountCreateTransaction()
                    .setKey(newAccountPublicKey)
                    .setInitialBalance(Hbar.fromTinybars(1000))
                    .execute(client);

            TransactionReceipt receipt = response.getReceipt(client);
            AccountId newAccountId = receipt.accountId;

            logger.info("Nouveau compte Hedera créé: {} pour l'utilisateur: {}", newAccountId, userEmail);

            return new HederaAccountInfo(
                    newAccountId.toString(),
                    newAccountPrivateKey.toString(),
                    newAccountPublicKey.toString()
            );

        } catch (Exception e) {
            logger.error("Erreur lors de la création du compte Hedera pour: {}", userEmail, e);
            throw new RuntimeException("Impossible de créer le compte Hedera", e);
        }
    }

    /**
     * Libère les fonds d'un compte de séquestre vers l'agriculteur et la plateforme
     */
    public String releaseFromEscrow(String escrowAccountId, String farmerAccountId, BigDecimal farmerAmount, String platformAccountId, BigDecimal platformAmount) {
        try {
            if (client == null || operatorKey == null) {
                String simulatedTxId = "0.0." + (System.currentTimeMillis() % 1000000) + "@" + (System.currentTimeMillis() / 1000);
                logger.info("Mode simulation - Libération du séquestre: {} HBAR vers l'agriculteur {}, {} HBAR vers la plateforme {}", 
                           farmerAmount, farmerAccountId, platformAmount, platformAccountId);
                return simulatedTxId;
            }

            AccountId escrowAccount = AccountId.fromString(escrowAccountId);
            AccountId farmerAccount = AccountId.fromString(farmerAccountId);
            AccountId platformAccount = AccountId.fromString(platformAccountId);

            long farmerTinybars = farmerAmount.multiply(BigDecimal.valueOf(100_000_000)).longValue();
            long platformTinybars = platformAmount.multiply(BigDecimal.valueOf(100_000_000)).longValue();
            long totalTinybars = farmerTinybars + platformTinybars;

            TransactionResponse response = new TransferTransaction()
                    .addHbarTransfer(escrowAccount, Hbar.fromTinybars(-totalTinybars))
                    .addHbarTransfer(farmerAccount, Hbar.fromTinybars(farmerTinybars))
                    .addHbarTransfer(platformAccount, Hbar.fromTinybars(platformTinybars))
                    .freezeWith(client)
                    .sign(operatorKey) // Signé par la clé de l'opérateur qui contrôle le compte de séquestre
                    .execute(client);

            String transactionId = response.transactionId.toString();
            logger.info("Libération du séquestre réussie (TX: {})", transactionId);
            return transactionId;

        } catch (Exception e) {
            logger.error("Erreur lors de la libération du séquestre depuis le compte {}", escrowAccountId, e);
            throw new RuntimeException("Échec de la libération du séquestre", e);
        }
    }

    /**
     * Transfère des HBAR entre deux comptes
     */
    public String transferHbar(String fromAccountId, String fromPrivateKey,
                               String toAccountId, BigDecimal amount) {
        try {
            if (client == null) {
                // Mode simulation
                String simulatedTxId = "0.0." + (System.currentTimeMillis() % 1000000) + "@" + 
                                     (System.currentTimeMillis() / 1000);
                logger.info("Mode simulation - Transfert HBAR: {} HBAR de {} vers {}", 
                           amount, fromAccountId, toAccountId);
                return simulatedTxId;
            }

            AccountId sender = AccountId.fromString(fromAccountId);
            AccountId receiver = AccountId.fromString(toAccountId);
            PrivateKey senderKey = PrivateKey.fromString(fromPrivateKey);

            long tinybars = amount.multiply(BigDecimal.valueOf(100_000_000)).longValue();

            TransactionResponse response = new TransferTransaction()
                    .addHbarTransfer(sender, Hbar.fromTinybars(-tinybars))
                    .addHbarTransfer(receiver, Hbar.fromTinybars(tinybars))
                    .freezeWith(client)
                    .sign(senderKey)
                    .execute(client);

            String transactionId = response.transactionId.toString();

            logger.info("Transfert HBAR réussi: {} HBAR de {} vers {} (TX: {})",
                    amount, fromAccountId, toAccountId, transactionId);

            return transactionId;

        } catch (Exception e) {
            logger.error("Erreur lors du transfert HBAR de {} vers {}", fromAccountId, toAccountId, e);
            throw new RuntimeException("Échec du transfert HBAR", e);
        }
    }

    public AccountId getOperatorId() {
        return operatorId;
    }

    public String getOperatorAccountId() {
        return operatorAccountId;
    }

    public Client getClient() {
        return client;
    }

    public PrivateKey getOperatorKey() {
        return operatorKey;
    }

    /**
     * Transfère des HBAR depuis le compte opérateur principal
     */
    public String transferHbarFromOperator(String toAccountId, BigDecimal amount) {
        if (operatorId == null || operatorKey == null) {
            throw new IllegalStateException("Le compte opérateur Hedera n'est pas configuré.");
        }
        return transferHbar(operatorId.toString(), operatorKey.toString(), toAccountId, amount);
    }

    /**
     * Récupère le solde d'un compte Hedera
     */
    public BigDecimal getAccountBalance(String accountId) {
        try {
            if (client == null) {
                // Mode simulation - retourner un solde aléatoire
                return BigDecimal.valueOf(Math.random() * 1000).setScale(8, BigDecimal.ROUND_HALF_UP);
            }

            AccountId account = AccountId.fromString(accountId);
            AccountBalance balance = new AccountBalanceQuery()
                    .setAccountId(account)
                    .execute(client);

            return BigDecimal.valueOf(balance.hbars.toTinybars())
                    .divide(BigDecimal.valueOf(100_000_000), 8, BigDecimal.ROUND_HALF_UP);

        } catch (Exception e) {
            logger.error("Erreur lors de la récupération du solde pour le compte: {}", accountId, e);
            return BigDecimal.ZERO;
        }
    }

    /**
     * Classe interne pour les informations de compte Hedera
     */
    public static class HederaAccountInfo {
        private final String accountId;
        private final String privateKey;
        private final String publicKey;

        public HederaAccountInfo(String accountId, String privateKey, String publicKey) {
            this.accountId = accountId;
            this.privateKey = privateKey;
            this.publicKey = publicKey;
        }

        public String getAccountId() { return accountId; }
        public String getPrivateKey() { return privateKey; }
        public String getPublicKey() { return publicKey; }
    }
}

