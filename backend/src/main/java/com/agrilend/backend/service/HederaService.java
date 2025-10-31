package com.agrilend.backend.service;

import com.hedera.hashgraph.sdk.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.Collections;

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

    private Client client;
    private AccountId operatorId;
    private PrivateKey operatorKey;

    @PostConstruct
    public void initializeClient() {
        try {
            if ("mainnet".equalsIgnoreCase(network)) {
                client = Client.forMainnet();
            } else {
                client = Client.forTestnet();
            }

            if (operatorAccountId != null && !operatorAccountId.isEmpty() &&
                    operatorPrivateKey != null && !operatorPrivateKey.isEmpty()) {

                operatorId = AccountId.fromString(operatorAccountId);
                operatorKey = PrivateKey.fromString(operatorPrivateKey);
                client.setOperator(operatorId, operatorKey);

                logger.info("Client Hedera initialisé avec succès sur le réseau: {}", network);
            } else {
                throw new IllegalStateException("Configuration Hedera incomplète: hedera.operator.account-id et/ou hedera.operator.private-key manquants");
            }

        } catch (Exception e) {
            logger.error("Erreur lors de l'initialisation du client Hedera", e);
        }
    }

    /**
     * Crée un token fongible (AgriToken) qui peut être minté et brûlé.
     * La supply est infinie pour permettre de minter des tokens à la demande.
     */
    public String createFungibleToken(String tokenName, String tokenSymbol, BigDecimal maxSupply, String treasuryAccountId) {
        try {
            AccountId treasury = AccountId.fromString(treasuryAccountId);

            TokenCreateTransaction tokenCreateTx = new TokenCreateTransaction()
                    .setTokenName(tokenName)
                    .setTokenSymbol(tokenSymbol)
                    .setDecimals(2) // e.g., 1.00 AgriToken
                    .setInitialSupply(0)
                    .setMaxSupply(maxSupply.longValue()) // Set max supply
                    .setTreasuryAccountId(treasury)
                    .setSupplyType(TokenSupplyType.FINITE) // Finite supply when maxSupply is set
                    .setSupplyKey(operatorKey) // Key to authorize minting
                    .setWipeKey(operatorKey) // Key to authorize burning
                    .setAdminKey(operatorKey)
                    .setFreezeDefault(false)
                    .setTokenMemo("Agrilend AgriToken");

            TransactionResponse response = tokenCreateTx.execute(client);
            TokenId tokenId = response.getReceipt(client).tokenId;

            logger.info("Token fongible (AgriToken) créé: {} ({})", tokenId, tokenSymbol);
            return tokenId.toString();

        } catch (Exception e) {
            logger.error("Erreur lors de la création du token fongible", e);
            throw new RuntimeException("Impossible de créer le token fongible", e);
        }
    }

    /**
     * Crée une transaction programmée pour le mint d'un token.
     * @param tokenId L'ID du token à minter.
     * @param amount Le montant à minter.
     * @param memo Un mémo pour la transaction.
     * @param receiptHash Le hash du reçu d'entrepôt.
     * @return L'ID du schedule.
     */
    public String createScheduledTokenMint(String tokenId, BigDecimal amount, String memo, String receiptHash) {
        try {
            TokenMintTransaction tokenMintTx = new TokenMintTransaction()
                    .setTokenId(TokenId.fromString(tokenId))
                    .setAmount(amount.longValue()); // Convert BigDecimal to long

            ScheduleCreateTransaction scheduleCreateTx = new ScheduleCreateTransaction()
                    .setScheduledTransaction(tokenMintTx)
                    .setAdminKey(operatorKey)
                    .setPayerAccountId(operatorId);

            TransactionResponse response = scheduleCreateTx.execute(client);
            ScheduleId scheduleId = response.getReceipt(client).scheduleId;

            logger.info("Transaction programmée de mint créée: {} pour le token {}", scheduleId, tokenId);
            return scheduleId.toString();

        } catch (Exception e) {
            logger.error("Erreur lors de la création de la transaction programmée de mint", e);
            throw new RuntimeException("Impossible de créer la transaction programmée de mint", e);
        }
    }

    /**
     * Signe une transaction programmée.
     * @param scheduleId L'ID du schedule à signer.
     * @param signer La clé privée de l'opérateur.
     * @return L'ID de la transaction.
     */
    public String signScheduledTransaction(String scheduleId, PrivateKey signer) {
        try {
            ScheduleSignTransaction scheduleSignTx = new ScheduleSignTransaction()
                    .setScheduleId(ScheduleId.fromString(scheduleId))
                    .freezeWith(client)
                    .sign(signer);

            TransactionResponse response = scheduleSignTx.execute(client);
            String transactionId = response.transactionId.toString();

            logger.info("Transaction programmée {} signée (TX: {})", scheduleId, transactionId);
            return transactionId;

        } catch (Exception e) {
            logger.error("Erreur lors de la signature de la transaction programmée {}", scheduleId, e);
            throw new RuntimeException("Impossible de signer la transaction programmée", e);
        }
    }

    /**
     * Récupère le solde HBAR d'un compte.
     * @param accountId L'ID du compte.
     * @return Le solde en HBAR.
     */
    public BigDecimal getAccountBalance(String accountId) {
        try {
            AccountBalanceQuery query = new AccountBalanceQuery()
                    .setAccountId(AccountId.fromString(accountId));

            Hbar balance = query.execute(client).hbars;
            return BigDecimal.valueOf(balance.toTinybars(), 8); // Convert tinybars to HBAR

        } catch (Exception e) {
            logger.error("Erreur lors de la récupération du solde du compte {}", accountId, e);
            throw new RuntimeException("Impossible de récupérer le solde du compte", e);
        }
    }

    /**
     * Transfère des HBAR entre comptes.
     * @param fromAccountId L'ID du compte expéditeur.
     * @param fromPrivateKey La clé privée de l'expéditeur.
     * @param toAccountId L'ID du compte destinataire.
     * @param amount Le montant en HBAR à transférer.
     * @return L'ID de la transaction.
     */
    public String transferHbar(String fromAccountId, PrivateKey fromPrivateKey, String toAccountId, BigDecimal amount) {
        try {
            TransferTransaction transferTx = new TransferTransaction()
                    .addHbarTransfer(AccountId.fromString(fromAccountId), Hbar.from(amount).negated())
                    .addHbarTransfer(AccountId.fromString(toAccountId), Hbar.from(amount))
                    .freezeWith(client)
                    .sign(fromPrivateKey);

            TransactionResponse response = transferTx.execute(client);
            String transactionId = response.transactionId.toString();

            logger.info("Transfert de {} HBAR de {} vers {} réussi (TX: {})", amount, fromAccountId, toAccountId, transactionId);
            return transactionId;

        } catch (Exception e) {
            logger.error("Erreur lors du transfert de HBAR", e);
            throw new RuntimeException("Impossible de transférer les HBAR", e);
        }
    }

    /**
     * Associe un token à un compte.
     * @param accountId L'ID du compte.
     * @param privateKey La clé privée du compte.
     * @param tokenId L'ID du token.
     * @return L'ID de la transaction.
     */
    public String associateTokenToAccount(String accountId, PrivateKey privateKey, String tokenId) {
        try {
            TokenAssociateTransaction tokenAssociateTx = new TokenAssociateTransaction()
                    .setAccountId(AccountId.fromString(accountId))
                    .setTokenIds(Collections.singletonList(TokenId.fromString(tokenId)))
                    .freezeWith(client)
                    .sign(privateKey);

            TransactionResponse response = tokenAssociateTx.execute(client);
            String transactionId = response.transactionId.toString();

            logger.info("Token {} associé au compte {} (TX: {})", tokenId, accountId, transactionId);
            return transactionId;

        } catch (Exception e) {
            logger.error("Erreur lors de l'association du token {} au compte {}", tokenId, accountId, e);
            throw new RuntimeException("Impossible d'associer le token au compte", e);
        }
    }

    /**
     * Soumet un message au Hedera Consensus Service (HCS).
     * @param topicId L'ID du topic HCS.
     * @param message Le message à soumettre.
     * @return L'ID de la transaction.
     */
    public String submitConsensusMessage(String topicId, String message) {
        try {
            TopicMessageSubmitTransaction submitMessageTx = new TopicMessageSubmitTransaction()
                    .setTopicId(TopicId.fromString(topicId))
                    .setMessage(message);

            TransactionResponse response = submitMessageTx.execute(client);
            String transactionId = response.transactionId.toString();

            logger.info("Message soumis au topic {} (TX: {})", topicId, transactionId);
            return transactionId;

        } catch (Exception e) {
            logger.error("Erreur lors de la soumission du message au topic {}", topicId, e);
            throw new RuntimeException("Impossible de soumettre le message au topic", e);
        }
    }

    /**
     * Récupère le reçu d'une transaction.
     * @param transactionId L'ID de la transaction.
     * @return Le reçu de la transaction.
     */
    public TransactionReceipt getTransactionReceipt(TransactionId transactionId) {
        try {
            return transactionId.getReceipt(client);
        } catch (Exception e) {
            logger.error("Erreur lors de la récupération du reçu de la transaction {}", transactionId, e);
            throw new RuntimeException("Impossible de récupérer le reçu de la transaction", e);
        }
    }

    /**
     * Crée un compte Hedera.
     * @param initialBalance Le solde initial du compte en HBAR.
     * @return Les informations du compte créé (AccountId et PrivateKey).
     */
    public HederaAccountInfo createAccount(BigDecimal initialBalance) {
        try {
            PrivateKey newAccountPrivateKey = PrivateKey.generateED25519();
            PublicKey newAccountPublicKey = newAccountPrivateKey.getPublicKey();

            AccountCreateTransaction accountCreateTx = new AccountCreateTransaction()
                    .setKey(newAccountPublicKey)
                    .setInitialBalance(Hbar.from(initialBalance));

            TransactionResponse response = accountCreateTx.execute(client);
            AccountId newAccountId = response.getReceipt(client).accountId;

            logger.info("Compte Hedera créé: {} avec solde initial de {} HBAR", newAccountId, initialBalance);
            return new HederaAccountInfo(newAccountId.toString(), newAccountPrivateKey.toString());

        } catch (Exception e) {
            logger.error("Erreur lors de la création du compte Hedera", e);
            throw new RuntimeException("Impossible de créer le compte Hedera", e);
        }
    }

    public static class HederaAccountInfo {
        private final String accountId;
        private final String privateKey;

        public HederaAccountInfo(String accountId, String privateKey) {
            this.accountId = accountId;
            this.privateKey = privateKey;
        }

        public String getAccountId() {
            return accountId;
        }

        public String getPrivateKey() {
            return privateKey;
        }
    }

    /**
     * Libère des fonds d'un escrow.
     * @param contractId L'ID du contrat escrow.
     * @param amount Le montant à libérer.
     * @param recipientAccountId L'ID du compte destinataire.
     * @param tokenToReleaseId L'ID du token à libérer (si applicable).
     * @param tokenAmountToRelease Le montant du token à libérer (si applicable).
     * @return L'ID de la transaction.
     */
    public String releaseFromEscrow(String contractId, BigDecimal amount, String recipientAccountId, String tokenToReleaseId, BigDecimal tokenAmountToRelease) {
        try {
            ContractExecuteTransaction tx = new ContractExecuteTransaction()
                .setContractId(ContractId.fromString(contractId))
                .setGas(200_000) // Gas for execution
                .setFunction("release", new ContractFunctionParameters()
                        .addUint256(amount.multiply(new BigDecimal("100000000")).toBigInteger()) // HBAR amount in tinybars
                        .addAddress(AccountId.fromString(recipientAccountId).toSolidityAddress())
                        .addAddress(TokenId.fromString(tokenToReleaseId).toSolidityAddress())
                        .addUint256(BigInteger.valueOf(tokenAmountToRelease.longValue()))); // Token amount

            TransactionResponse response = tx.execute(client);
            String txId = response.transactionId.toString();
            logger.info("Libération de {} HBAR et {} tokens {} de l'escrow {} vers {} initiée (TX: {})", amount, tokenAmountToRelease, tokenToReleaseId, contractId, recipientAccountId, txId);
            return txId;

        } catch (Exception e) {
            logger.error("Erreur lors de la libération de l'escrow {}", contractId, e);
            throw new RuntimeException("Échec de la libération de l'escrow", e);
        }
    }


    /**
     * Crée (minte) une nouvelle quantité d'un token.
     * @param tokenId L'ID du token à minter.
     * @param amount Le montant à créer (en plus petite unité, ex: centimes).
     */
    public String mintToken(String tokenId, long amount) {
        try {
            TokenMintTransaction mintTx = new TokenMintTransaction()
                    .setTokenId(TokenId.fromString(tokenId))
                    .setAmount(amount);

            TransactionResponse response = mintTx.execute(client);
            String txId = response.transactionId.toString();
            logger.info("Mint de {} tokens pour le token {} réussi (TX: {})", amount, tokenId, txId);
            return txId;
        } catch (Exception e) {
            logger.error("Erreur lors du mint du token {}", tokenId, e);
            throw new RuntimeException("Échec du mint de token", e);
        }
    }

    /**
     * Brûle (wipe) une quantité de token du compte d'un utilisateur.
     * @param tokenId L'ID du token à brûler.
     * @param accountId Le compte de l'utilisateur dont les tokens seront brûlés.
     * @param amount Le montant à brûler (en plus petite unité).
     */
    public String burnToken(String tokenId, String accountId, long amount) {
        try {
            TokenWipeTransaction wipeTx = new TokenWipeTransaction()
                    .setTokenId(TokenId.fromString(tokenId))
                    .setAccountId(AccountId.fromString(accountId))
                    .setAmount(amount);

            TransactionResponse response = wipeTx.execute(client);
            String txId = response.transactionId.toString();
            logger.info("Burn de {} tokens du compte {} pour le token {} réussi (TX: {})", amount, accountId, tokenId, txId);
            return txId;
        } catch (Exception e) {
            logger.error("Erreur lors du burn du token {} pour le compte {}", tokenId, accountId, e);
            throw new RuntimeException("Échec du burn de token", e);
        }
    }

    /**
     * Transfère des tokens entre comptes.
     */
    public String transferTokens(String tokenId, String fromAccountId, String toAccountId, long amount) {
        try {
            TransferTransaction transferTx = new TransferTransaction()
                    .addTokenTransfer(TokenId.fromString(tokenId), AccountId.fromString(fromAccountId), -amount)
                    .addTokenTransfer(TokenId.fromString(tokenId), AccountId.fromString(toAccountId), amount)
                    .freezeWith(client);
            
            // Note: This assumes the sender's key is available or the platform operator has control.
            // For a real scenario, this would need to be signed by the 'fromAccount' user.
            // For now, we assume the operator is the one initiating transfers.
            TransactionResponse response = transferTx.execute(client);
            String transactionId = response.transactionId.toString();

            logger.info("Tokens transférés: {} {} de {} vers {}", amount, tokenId, fromAccountId, toAccountId);
            return transactionId;

        } catch (Exception e) {
            logger.error("Erreur lors du transfert de tokens", e);
            throw new RuntimeException("Impossible de transférer les tokens", e);
        }
    }

    /**
     * Prépare une transaction non signée pour l'association d'un token HTS à un compte Hedera.
     * Cette transaction doit être signée par l'utilisateur côté client.
     * @param accountId L'ID du compte Hedera de l'utilisateur.
     * @param tokenId L'ID du token à associer.
     * @return La transaction sérialisée en Base64.
     */
    public String prepareTokenAssociateTransaction(String accountId, String tokenId) {
        try {
            TokenAssociateTransaction transaction = new TokenAssociateTransaction()
                    .setAccountId(AccountId.fromString(accountId))
                    .setTokenIds(Collections.singletonList(TokenId.fromString(tokenId)))
                    .freezeWith(client);
            
            // La transaction n'est PAS signée ici. Elle sera signée par l'utilisateur.
            return java.util.Base64.getEncoder().encodeToString(transaction.toBytes());

        } catch (Exception e) {
            logger.error("Erreur lors de la préparation de la transaction d'association pour le compte {} et le token {}", accountId, tokenId, e);
            throw new RuntimeException("Impossible de préparer la transaction d'association", e);
        }
    }

    /**
     * Retire des HBAR du HarvestVault smart contract pour payer un agriculteur.
     */
    public String withdrawFromVault(String contractId, BigDecimal amountToWithdraw, String recipientAccountId) {
        try {
            ContractExecuteTransaction tx = new ContractExecuteTransaction()
                .setContractId(ContractId.fromString(contractId))
                .setGas(150_000) // Gas for withdrawal execution
                .setFunction("withdrawHbar", new ContractFunctionParameters()
                        .addUint256(amountToWithdraw.multiply(new BigDecimal("100000000")).toBigInteger()) // tinybars
                        .addAddress(AccountId.fromString(recipientAccountId).toSolidityAddress()));
            
            TransactionResponse response = tx.execute(client);
            String txId = response.transactionId.toString();
            logger.info("Retrait de {} HBAR du vault {} vers {} initié (TX: {})", amountToWithdraw, contractId, recipientAccountId, txId);
            return txId;

        } catch (Exception e) {
            logger.error("Erreur lors du retrait du vault {}", contractId, e);
            throw new RuntimeException("Échec du retrait du vault", e);
        }
    }

    // Getters and other utility methods...
    public Client getClient() { return client; }
    public AccountId getOperatorId() { return operatorId; }
    public PrivateKey getOperatorKey() { return operatorKey; }

    /**
     * Prépare une transaction non signée pour le transfert de HBAR.
     * Cette transaction doit être signée par l'utilisateur côté client.
     * @param fromAccountId L'ID du compte Hedera de l'expéditeur.
     * @param toAccountId L'ID du compte Hedera du destinataire.
     * @param amount Le montant en HBAR à transférer.
     * @return La transaction sérialisée en Base64.
     */
    public String prepareHbarTransferTransaction(String fromAccountId, String toAccountId, BigDecimal amount) {
        try {
            TransferTransaction transaction = new TransferTransaction()
                    .addHbarTransfer(AccountId.fromString(fromAccountId), Hbar.from(amount).negated())
                    .addHbarTransfer(AccountId.fromString(toAccountId), Hbar.from(amount))
                    .freezeWith(client);

            // La transaction n'est PAS signée ici. Elle sera signée par l'utilisateur.
            return java.util.Base64.getEncoder().encodeToString(transaction.toBytes());

        } catch (Exception e) {
            logger.error("Erreur lors de la préparation de la transaction de transfert HBAR de {} vers {}", fromAccountId, toAccountId, e);
            throw new RuntimeException("Impossible de préparer la transaction de transfert HBAR", e);
        }
    }

    /**
     * Soumet une transaction Hedera signée au réseau.
     * @param signedTransactionBytes Base64 encodé des bytes de la transaction signée.
     * @return L'ID de la transaction soumise.
     */
    public String submitSignedTransaction(String signedTransactionBytes) {
        try {
            byte[] transactionBytes = java.util.Base64.getDecoder().decode(signedTransactionBytes);
            Transaction transaction = Transaction.fromBytes(transactionBytes);

            TransactionResponse response = (TransactionResponse) transaction.execute(client);
            String txId = response.transactionId.toString();

            logger.info("Transaction signée soumise au réseau Hedera. TX ID: {}", txId);
            return txId;

        } catch (Exception e) {
            logger.error("Erreur lors de la soumission de la transaction signée: {}", e.getMessage(), e);
            throw new RuntimeException("Impossible de soumettre la transaction signée", e);
        }
    }
}
