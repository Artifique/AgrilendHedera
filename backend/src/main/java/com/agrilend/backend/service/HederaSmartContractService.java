package com.agrilend.backend.service;

import com.hedera.hashgraph.sdk.*;
import com.hedera.hashgraph.sdk.ContractFunctionResult;
import com.hedera.hashgraph.sdk.ContractCallQuery;
import com.hedera.hashgraph.sdk.AccountId;
import com.hedera.hashgraph.sdk.TokenId;
import com.agrilend.backend.dto.tokenization.DeployFactoryRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import io.grpc.StatusRuntimeException;
import java.math.BigInteger;
import java.time.Duration;

/**
 * Service d'opérations Smart Contracts Hedera.
 */
@Service
public class HederaSmartContractService {

    private static final Logger logger = LoggerFactory.getLogger(HederaSmartContractService.class);

    @Autowired
    private HederaService hederaService;

    /**
     * Déploie un contrat (ex: HarvestVault) à partir d'un bytecode hexadécimal (sans préfixe 0x)
     */
    public String deployContractFromBytecodeHex(DeployFactoryRequest request) {
        try {
            Client client = hederaService.getClient();
            PrivateKey operatorKey = hederaService.getOperatorKey();
            if (client == null || operatorKey == null) {
                throw new IllegalStateException("Client Hedera non initialisé (fournir operator account/private key)");
            }

            byte[] bytecode = hexStringToByteArray(request.getBytecodeHex());

            // Encode constructor parameters
            ContractFunctionParameters constructorParameters = new ContractFunctionParameters()
                .addAddress(AccountId.fromString(request.getWarehouseAccountAddress()).toSolidityAddress())
                .addAddress(TokenId.fromString(request.getRewardTokenAddress()).toSolidityAddress())
                .addUint256(BigInteger.valueOf(request.getDepositDurationSeconds()))
                .addUint256(BigInteger.valueOf(request.getRewardPerHbar()));

            ContractCreateFlow contractCreateFlow = new ContractCreateFlow()
                .setBytecode(bytecode)
                .setConstructorParameters(constructorParameters)
                .setGas(4_000_000)
                .setAdminKey(operatorKey.getPublicKey());

            TransactionResponse response = contractCreateFlow.execute(client);
            TransactionReceipt receipt = response.getReceipt(client);

            if (receipt.contractId != null) {
                logger.info("Contrat déployé: {}", receipt.contractId);
                return receipt.contractId.toString();
            } else {
                throw new RuntimeException("Échec du déploiement du contrat, ID de contrat nul");
            }

        } catch (StatusRuntimeException e) {
            logger.error("Échec du déploiement de contrat: Status: {} Description: {}", e.getStatus().getCode(), e.getStatus().getDescription(), e);
            throw new RuntimeException("Impossible de déployer le contrat", e);
        } catch (Exception e) {
            logger.error("Échec du déploiement de contrat", e);
            throw new RuntimeException("Impossible de déployer le contrat", e);
        }
    }

    /**
     * Appelle une fonction de lecture (view function) sur un smart contract.
     * Utile pour récupérer des données sans modifier l'état du contrat ni payer de frais de gaz élevés.
     * @param contractId L'ID du contrat.
     * @param functionName Le nom de la fonction à appeler (ex: "getDepositors").
     * @param parameters Les paramètres de la fonction (peut être vide pour les fonctions sans arguments).
     * @return Le résultat de l'exécution de la fonction du contrat.
     */
    public ContractFunctionResult callContractViewFunction(String contractId, String functionName, ContractFunctionParameters parameters) {
        try {
            Client client = hederaService.getClient();
            if (client == null) {
                throw new IllegalStateException("Client Hedera non initialisé");
            }
            if (parameters == null) {
                parameters = new ContractFunctionParameters();
            }

            ContractCallQuery contractQuery = new ContractCallQuery()
                    .setContractId(ContractId.fromString(contractId))
                    .setGas(100_000) // Ajuster le gaz pour l'exécution d'une fonction de lecture
                    .setFunction(functionName, parameters)
                    .setMaxQueryPayment(new Hbar(1)); // Coût maximal de la requête

            ContractFunctionResult result = contractQuery.execute(client);
            logger.debug("Appel de fonction de contrat '{}' sur {} réussi.", functionName, contractId);
            return result;
        } catch (Exception e) {
            logger.error("Échec de l'appel de fonction de contrat '{}' sur {}", functionName, contractId, e);
            throw new RuntimeException("Impossible d'appeler la fonction de contrat: " + functionName, e);
        }
    }

    // Helper pour convertir une string hexadécimale en tableau de bytes
    private static byte[] hexStringToByteArray(String s) {
        int len = s.length();
        if (len % 2 != 0) {
            throw new IllegalArgumentException("La longueur de la chaîne hexadécimale doit être paire");
        }
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
                    + Character.digit(s.charAt(i + 1), 16));
        }
        return data;
    }
}