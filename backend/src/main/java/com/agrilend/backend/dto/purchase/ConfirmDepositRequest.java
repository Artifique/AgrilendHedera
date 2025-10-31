package com.agrilend.backend.dto.purchase;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;

public class ConfirmDepositRequest {

    @NotBlank
    private String hederaTransactionId;

    @NotNull
    @Positive
    private BigDecimal hbarAmount;

    // Getters and Setters

    public String getHederaTransactionId() {
        return hederaTransactionId;
    }

    public void setHederaTransactionId(String hederaTransactionId) {
        this.hederaTransactionId = hederaTransactionId;
    }

    public BigDecimal getHbarAmount() {
        return hbarAmount;
    }

    public void setHbarAmount(BigDecimal hbarAmount) {
        this.hbarAmount = hbarAmount;
    }
}
