package com.agrilend.backend.dto.tokenization;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public class DeployFactoryRequest {

    @NotBlank
    private String bytecodeHex;

    @NotBlank
    private String warehouseAccountAddress; // Hedera Account ID as a string

    @NotBlank
    private String rewardTokenAddress; // Hedera Token ID as a string

    @NotNull
    @Positive
    private Long depositDurationSeconds;

    @NotNull
    @Positive
    private Long rewardPerHbar;

    public String getBytecodeHex() { return bytecodeHex; }
    public void setBytecodeHex(String bytecodeHex) { this.bytecodeHex = bytecodeHex; }

    public String getWarehouseAccountAddress() { return warehouseAccountAddress; }
    public void setWarehouseAccountAddress(String warehouseAccountAddress) { this.warehouseAccountAddress = warehouseAccountAddress; }

    public String getRewardTokenAddress() { return rewardTokenAddress; }
    public void setRewardTokenAddress(String rewardTokenAddress) { this.rewardTokenAddress = rewardTokenAddress; }

    public Long getDepositDurationSeconds() { return depositDurationSeconds; }
    public void setDepositDurationSeconds(Long depositDurationSeconds) { this.depositDurationSeconds = depositDurationSeconds; }

    public Long getRewardPerHbar() { return rewardPerHbar; }
    public void setRewardPerHbar(Long rewardPerHbar) { this.rewardPerHbar = rewardPerHbar; }
}

