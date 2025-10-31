package com.agrilend.backend.dto.tokenization;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class CreatePoolRequest {

    @NotBlank
    private String factoryContractId;

    @NotBlank
    private String name;

    @NotBlank
    private String tokenId;

    @NotNull
    @Min(1)
    private Long depositDurationSec;

    @NotNull
    @Min(1)
    private Long rewardPerHbar;

    public String getFactoryContractId() { return factoryContractId; }
    public void setFactoryContractId(String factoryContractId) { this.factoryContractId = factoryContractId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getTokenId() { return tokenId; }
    public void setTokenId(String tokenId) { this.tokenId = tokenId; }

    public Long getDepositDurationSec() { return depositDurationSec; }
    public void setDepositDurationSec(Long depositDurationSec) { this.depositDurationSec = depositDurationSec; }

    public Long getRewardPerHbar() { return rewardPerHbar; }
    public void setRewardPerHbar(Long rewardPerHbar) { this.rewardPerHbar = rewardPerHbar; }
}


