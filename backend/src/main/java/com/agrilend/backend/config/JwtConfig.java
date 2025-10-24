package com.agrilend.backend.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "app.jwt")
public class JwtConfig {
    
    private String secret = "AgrilendSuperSecretKeyForJWTTokenGenerationAndValidationSecurely2024!@#$";
    private int expirationInMs = 86400000; // 24 heures
    private int refreshExpirationInMs = 604800000; // 7 jours

    public String getSecret() {
        return secret;
    }

    public void setSecret(String secret) {
        this.secret = secret;
    }

    public int getExpirationInMs() {
        return expirationInMs;
    }

    public void setExpirationInMs(int expirationInMs) {
        this.expirationInMs = expirationInMs;
    }

    public int getRefreshExpirationInMs() {
        return refreshExpirationInMs;
    }

    public void setRefreshExpirationInMs(int refreshExpirationInMs) {
        this.refreshExpirationInMs = refreshExpirationInMs;
    }
}

