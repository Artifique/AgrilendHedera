package com.agrilend.backend.util;

import com.agrilend.backend.AgrilendBackendApplication;
import com.agrilend.backend.service.HederaService;
import com.hedera.hashgraph.sdk.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;

import java.math.BigDecimal;

//@SpringBootApplication
@ComponentScan(basePackages = "com.agrilend.backend")
public class HederaSetup {

    @Autowired
    private HederaService hederaService;

    public static void main(String[] args) {
        SpringApplication.run(HederaSetup.class, args);
    }

    @Bean
    public CommandLineRunner run() {
        return args -> {
            System.out.println("--- Démarrage de la configuration Hedera ---");

            // 1. Créer un compte de trésorerie dédié
            System.out.println("\n--- Création du compte de trésorerie ---");
            HederaService.HederaAccountInfo treasuryAccountInfo = hederaService.createAccount("agrilend_treasury@example.com");
            System.out.println("Nouveau compte de trésorerie créé:");
            System.out.println("  Account ID: " + treasuryAccountInfo.getAccountId());
            System.out.println("  Private Key: " + treasuryAccountInfo.getPrivateKey()); // Gardez cette clé SECRÈTE
            System.out.println("  Public Key: " + treasuryAccountInfo.getPublicKey());
            String treasuryAccountId = treasuryAccountInfo.getAccountId();
            PrivateKey treasuryPrivateKey = PrivateKey.fromString(treasuryAccountInfo.getPrivateKey());

            // 1.5 Transférer des HBAR au compte de trésorerie pour les frais
            System.out.println("\n--- Transfert de HBAR au compte de trésorerie ---");
            TransferTransaction transferTx = new TransferTransaction()
                    .addHbarTransfer(hederaService.getOperatorId(), Hbar.from(-10)) // Envoyer 10 HBAR
                    .addHbarTransfer(AccountId.fromString(treasuryAccountId), Hbar.from(10));

            TransactionResponse transferResponse = transferTx.execute(hederaService.getClient());
            TransactionReceipt transferReceipt = transferResponse.getReceipt(hederaService.getClient());
            System.out.println("Transfert de HBAR effectué. Status: " + transferReceipt.status);

            // Attendre un peu pour que le transfert soit bien propagé
            Thread.sleep(2000);

            // 2. Créer un Topic HCS
            System.out.println("\n--- Création du Topic HCS ---");
            TopicCreateTransaction topicCreateTx = new TopicCreateTransaction()
                    .setAdminKey(hederaService.getOperatorKey());
            TransactionResponse topicResponse = topicCreateTx.execute(hederaService.getClient());
            TopicId topicId = topicResponse.getReceipt(hederaService.getClient()).topicId;
            System.out.println("Nouveau Topic HCS créé:");
            System.out.println("  Topic ID: " + topicId.toString());

            // 3. Créer un Token Fongible en utilisant le compte opérateur comme trésorerie
            System.out.println("\n--- Création du Token Fongible ---");

            // Option 1: Utiliser le compte opérateur comme trésorerie (plus simple)
            TokenCreateTransaction tokenCreateTx = new TokenCreateTransaction()
                    .setTokenName("AgriLend Harvest Token")
                    .setTokenSymbol("AGRI")
                    .setDecimals(0)
                    .setInitialSupply(0)
                    .setSupplyType(TokenSupplyType.FINITE)
                    .setMaxSupply(1000L)
                    .setTreasuryAccountId(hederaService.getOperatorId()) // Utiliser le compte opérateur
                    .setSupplyKey(hederaService.getOperatorKey())
                    .setAdminKey(hederaService.getOperatorKey())
                    .setFreezeDefault(false)
                    .setTokenMemo("Harvest token for AgriLend");

            TransactionResponse tokenResponse = tokenCreateTx.execute(hederaService.getClient());
            TokenId tokenId = tokenResponse.getReceipt(hederaService.getClient()).tokenId;
            System.out.println("Nouveau Token Fongible créé:");
            System.out.println("  Token ID: " + tokenId.toString());

            // 4. Associer le token au compte de trésorerie créé
            System.out.println("\n--- Association du token au compte de trésorerie ---");
            try {
                // D'abord, créer un client temporaire pour le compte de trésorerie
                Client treasuryClient = Client.forTestnet();
                treasuryClient.setOperator(AccountId.fromString(treasuryAccountId), treasuryPrivateKey);

                TokenAssociateTransaction associateTx = new TokenAssociateTransaction()
                        .setAccountId(AccountId.fromString(treasuryAccountId))
                        .setTokenIds(java.util.Collections.singletonList(tokenId));

                TransactionResponse associateResponse = associateTx.execute(treasuryClient);
                TransactionReceipt associateReceipt = associateResponse.getReceipt(treasuryClient);
                System.out.println("Token associé au compte de trésorerie. Status: " + associateReceipt.status);

                treasuryClient.close();
            } catch (Exception e) {
                System.out.println("Erreur lors de l'association du token: " + e.getMessage());
            }

            System.out.println("\n--- Configuration Hedera terminée ---");
            System.out.println("Veuillez mettre à jour votre fichier application.properties avec les IDs ci-dessus:");
            System.out.println("  hedera.treasury.account.id=" + treasuryAccountId);
            System.out.println("  hedera.treasury.private.key=" + treasuryAccountInfo.getPrivateKey());
            System.out.println("  hedera.topic.id=" + topicId.toString());
            System.out.println("  hedera.token.id=" + tokenId.toString());
        };
    }
}