package com.agrilend.backend.dto.user;

import jakarta.validation.constraints.NotBlank;

public class LinkHederaAccountRequest {

    @NotBlank
    private String hederaAccountId;

    public String getHederaAccountId() {
        return hederaAccountId;
    }

    public void setHederaAccountId(String hederaAccountId) {
        this.hederaAccountId = hederaAccountId;
    }
}
