package com.agrilend.backend.dto.tokenization;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

public class PayFarmerRequest {

    @NotBlank
    private String vaultContractId;

    @NotBlank
    private String farmerAccountId;

    @NotNull
    private BigDecimal amount;

    public String getVaultContractId() {
        return vaultContractId;
    }

    public void setVaultContractId(String vaultContractId) {
        this.vaultContractId = vaultContractId;
    }

    public String getFarmerAccountId() {
        return farmerAccountId;
    }

    public void setFarmerAccountId(String farmerAccountId) {
        this.farmerAccountId = farmerAccountId;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }
}
