package com.agrilend.backend.dto.purchase;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;

public class RedeemRequest {

    @NotBlank
    private String tokenId; // The AgriToken ID

    @NotNull
    @Positive
    private BigDecimal amount; // Amount of AgriTokens to redeem

    // Getters and Setters

    public String getTokenId() {
        return tokenId;
    }

    public void setTokenId(String tokenId) {
        this.tokenId = tokenId;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }
}
