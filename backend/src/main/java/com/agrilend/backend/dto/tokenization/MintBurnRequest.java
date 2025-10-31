package com.agrilend.backend.dto.tokenization;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;

public class MintBurnRequest {

    @NotBlank
    private String tokenId;

    // For burning, this is the account to burn from
    private String accountId;

    @Positive
    private long amount;

    public String getTokenId() {
        return tokenId;
    }

    public void setTokenId(String tokenId) {
        this.tokenId = tokenId;
    }

    public String getAccountId() {
        return accountId;
    }

    public void setAccountId(String accountId) {
        this.accountId = accountId;
    }

    public long getAmount() {
        return amount;
    }

    public void setAmount(long amount) {
        this.amount = amount;
    }
}
