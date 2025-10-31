package com.agrilend.backend.dto.tokenization;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class PoolDepositRequest {

    @NotBlank
    private String poolAddress; // EVM address (with or without 0x)

    @NotNull
    @Min(1)
    private Long amountHbar;

    public String getPoolAddress() { return poolAddress; }
    public void setPoolAddress(String poolAddress) { this.poolAddress = poolAddress; }

    public Long getAmountHbar() { return amountHbar; }
    public void setAmountHbar(Long amountHbar) { this.amountHbar = amountHbar; }
}


