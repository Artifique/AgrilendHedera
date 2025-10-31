package com.agrilend.backend.dto.tokenization;

import jakarta.validation.constraints.NotBlank;

public class DistributeRewardsRequest {

    @NotBlank
    private String poolAddress; // EVM address

    public String getPoolAddress() { return poolAddress; }
    public void setPoolAddress(String poolAddress) { this.poolAddress = poolAddress; }
}


