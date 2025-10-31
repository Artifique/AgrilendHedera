package com.agrilend.backend.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("AgriLend API")
                .description("API RESTful pour la plateforme AgriLend, une solution innovante de tokenisation agricole basée sur Hedera Hashgraph. Cette API gère l'ensemble du cycle de vie des produits agricoles, de la création d'offres par les agriculteurs à l'achat par les acheteurs, en passant par la tokenisation des récoltes et la gestion des transactions sur le réseau Hedera. Elle intègre des fonctionnalités d'authentification JWT, de gestion des utilisateurs (agriculteurs, acheteurs, administrateurs), de suivi des commandes et des livraisons, et de statistiques de tableau de bord. Les contrats intelligents Hedera (HbarToTokenPoolHTS et PoolFactory) sont utilisés pour la gestion des dépôts HBAR et la distribution de tokens HTS représentant les récoltes.")
                .version("1.0.0")
                .contact(new Contact()
                    .name("Équipe AgriLend")
                    .email("contact@agrilend.com")
                    .url("https://agrilend.com"))
                .license(new License()
                    .name("MIT License")
                    .url("https://opensource.org/licenses/MIT")))
            .addSecurityItem(new SecurityRequirement().addList("bearerAuth"))
            .components(new Components()
                .addSecuritySchemes("bearerAuth", new SecurityScheme()
                    .type(SecurityScheme.Type.HTTP)
                    .scheme("bearer")
                    .bearerFormat("JWT")
                    .description("Token JWT pour l'authentification")));
    }
}

