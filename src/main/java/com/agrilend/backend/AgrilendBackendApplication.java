package com.agrilend.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.transaction.annotation.EnableTransactionManagement;

/**
 * Application principale Spring Boot pour Agrilend
 * Plateforme de tokenisation des récoltes agricoles avec intégration Hedera
 */
@SpringBootApplication
@EnableAsync
@EnableTransactionManagement
public class AgrilendBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(AgrilendBackendApplication.class, args);
    }
}

