package com.agrilend.backend.config;

import com.hedera.hashgraph.sdk.Client;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class HederaConfig {

    @Value("${hedera.network:testnet}")
    private String network;

    @Value("${hedera.operator.account.id:}")
    private String operatorAccountId;

    @Value("${hedera.operator.private.key:}")
    private String operatorPrivateKey;

    @Bean
    public Client hederaClient() {
        Client client;
        
        if ("mainnet".equalsIgnoreCase(network)) {
            client = Client.forMainnet();
        } else {
            client = Client.forTestnet();
        }

        if (!operatorAccountId.isEmpty() && !operatorPrivateKey.isEmpty()) {
            client.setOperator(
                com.hedera.hashgraph.sdk.AccountId.fromString(operatorAccountId),
                com.hedera.hashgraph.sdk.PrivateKey.fromString(operatorPrivateKey)
            );
        }

        return client;
    }
}

