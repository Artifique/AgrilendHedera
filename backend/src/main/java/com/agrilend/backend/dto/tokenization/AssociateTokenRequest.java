package com.agrilend.backend.dto.tokenization;

import jakarta.validation.constraints.NotBlank;

public class AssociateTokenRequest {

    @NotBlank
    private String accountId;

    @NotBlank
    private String accountPrivateKey;

    @NotBlank
    private String tokenId;

    public String getAccountId() { return accountId; }
    public void setAccountId(String accountId) { this.accountId = accountId; }

    public String getAccountPrivateKey() { return accountPrivateKey; }
    public void setAccountPrivateKey(String accountPrivateKey) { this.accountPrivateKey = accountPrivateKey; }

    public String getTokenId() { return tokenId; }
    public void setTokenId(String tokenId) { this.tokenId = tokenId; }
}


