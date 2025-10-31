package com.agrilend.backend.dto.tokenization;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public class CreateTokenRequest {

    @NotBlank
    private String tokenName;

    @NotBlank
    private String tokenSymbol;

    @NotNull
    @Min(1)
    private BigDecimal maxSupply;

    @NotBlank
    private String treasuryAccountId;

    @NotNull
    private Long warehouseReceiptId;

    public String getTokenName() { return tokenName; }
    public void setTokenName(String tokenName) { this.tokenName = tokenName; }

    public String getTokenSymbol() { return tokenSymbol; }
    public void setTokenSymbol(String tokenSymbol) { this.tokenSymbol = tokenSymbol; }

    public BigDecimal getMaxSupply() { return maxSupply; }
    public void setMaxSupply(BigDecimal maxSupply) { this.maxSupply = maxSupply; }

    public String getTreasuryAccountId() { return treasuryAccountId; }
    public void setTreasuryAccountId(String treasuryAccountId) { this.treasuryAccountId = treasuryAccountId; }

    public Long getWarehouseReceiptId() { return warehouseReceiptId; }
    public void setWarehouseReceiptId(Long warehouseReceiptId) { this.warehouseReceiptId = warehouseReceiptId; }
}


