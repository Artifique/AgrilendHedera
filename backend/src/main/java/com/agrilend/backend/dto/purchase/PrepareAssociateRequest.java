package com.agrilend.backend.dto.purchase;

import jakarta.validation.constraints.NotBlank;

public class PrepareAssociateRequest {

    @NotBlank
    private String tokenId;

    public String getTokenId() {
        return tokenId;
    }

    public void setTokenId(String tokenId) {
        this.tokenId = tokenId;
    }
}
