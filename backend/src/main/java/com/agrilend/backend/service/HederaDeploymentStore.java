package com.agrilend.backend.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Stockage simple des IDs déployés (équivalent à deployed.json côté Node)
 */
@Component
public class HederaDeploymentStore {

    private static final Logger logger = LoggerFactory.getLogger(HederaDeploymentStore.class);
    private static final Path STORE_PATH = Paths.get("target", "hedera-deployed.json");
    private final ObjectMapper mapper = new ObjectMapper();

    public synchronized Map<String, Object> load() {
        try {
            if (!Files.exists(STORE_PATH)) {
                return new HashMap<>();
            }
            byte[] bytes = Files.readAllBytes(STORE_PATH);
            return mapper.readValue(bytes, new TypeReference<Map<String, Object>>(){});
        } catch (IOException e) {
            logger.warn("Impossible de lire le store de déploiement, retour vide", e);
            return new HashMap<>();
        }
    }

    public synchronized void saveFactoryContractId(String contractId) {
        Map<String, Object> current = load();
        current.put("factoryContractId", contractId);
        persist(current);
    }

    public synchronized void addPool(Map<String, Object> poolInfo) {
        Map<String, Object> current = load();
        List<Map<String, Object>> pools = (List<Map<String, Object>>) current.get("pools");
        if (pools == null) pools = new ArrayList<>();
        pools.add(poolInfo);
        current.put("pools", pools);
        current.put("lastPoolAddress", poolInfo.get("address"));
        persist(current);
    }

    private void persist(Map<String, Object> data) {
        try {
            if (!Files.exists(STORE_PATH.getParent())) {
                Files.createDirectories(STORE_PATH.getParent());
            }
            byte[] out = mapper.writerWithDefaultPrettyPrinter().writeValueAsBytes(data);
            Files.write(STORE_PATH, out);
        } catch (IOException e) {
            logger.error("Échec d'écriture du store de déploiement", e);
        }
    }
}


