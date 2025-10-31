package com.agrilend.backend.dto.tokenization;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;

public class DistributeTokensRequest {

    @NotBlank
    private String tokenId;

    @NotBlank
    private String vaultContractId;

    @NotNull
    @Positive
    private BigDecimal totalAgriTokensToDistribute;

    // Getters and Setters

    public String getTokenId() {
        return tokenId;
    }

    public void setTokenId(String tokenId) {
        this.tokenId = tokenId;
    }

    public String getVaultContractId() {
        return vaultContractId;
    }

    public void setVaultContractId(String vaultContractId) {
        this.vaultContractId = vaultContractId;
    }

    public BigDecimal getTotalAgriTokensToDistribute() {
        return totalAgriTokensToDistribute;
    }

    public void setTotalAgriTokensToDistribute(BigDecimal totalAgriTokensToDistribute) {
        this.totalAgriTokensToDistribute = totalAgriTokensToDistribute;
    }
}
