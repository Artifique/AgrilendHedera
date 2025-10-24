package com.agrilend.backend.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Token représentant une récolte tokenisée sur Hedera
 */
@Entity
@Table(name = "harvest_tokens")
public class HarvestToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "warehouse_receipt_id", nullable = false)
    private WarehouseReceipt warehouseReceipt;

    @NotNull
    @Column(name = "hedera_token_id", unique = true, nullable = false)
    private String hederaTokenId;

    @NotNull
    @Column(name = "token_name", nullable = false)
    private String tokenName;

    @NotNull
    @Column(name = "token_symbol", nullable = false)
    private String tokenSymbol;

    @NotNull
    @Positive
    @Column(name = "total_supply", nullable = false, precision = 15, scale = 0)
    private BigDecimal totalSupply;

    @NotNull
    @Positive
    @Column(name = "max_supply", nullable = false, precision = 15, scale = 0)
    private BigDecimal maxSupply;

    @NotNull
    @Column(name = "minted_amount", nullable = false, precision = 15, scale = 0)
    private BigDecimal mintedAmount = BigDecimal.ZERO;

    @NotNull
    @Column(name = "treasury_account_id", nullable = false)
    private String treasuryAccountId;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "metadata", columnDefinition = "JSON")
    private String metadata;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Getters and Setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public WarehouseReceipt getWarehouseReceipt() {
        return warehouseReceipt;
    }

    public void setWarehouseReceipt(WarehouseReceipt warehouseReceipt) {
        this.warehouseReceipt = warehouseReceipt;
    }

    public String getHederaTokenId() {
        return hederaTokenId;
    }

    public void setHederaTokenId(String hederaTokenId) {
        this.hederaTokenId = hederaTokenId;
    }

    public String getTokenName() {
        return tokenName;
    }

    public void setTokenName(String tokenName) {
        this.tokenName = tokenName;
    }

    public String getTokenSymbol() {
        return tokenSymbol;
    }

    public void setTokenSymbol(String tokenSymbol) {
        this.tokenSymbol = tokenSymbol;
    }

    public BigDecimal getTotalSupply() {
        return totalSupply;
    }

    public void setTotalSupply(BigDecimal totalSupply) {
        this.totalSupply = totalSupply;
    }

    public BigDecimal getMaxSupply() {
        return maxSupply;
    }

    public void setMaxSupply(BigDecimal maxSupply) {
        this.maxSupply = maxSupply;
    }

    public BigDecimal getMintedAmount() {
        return mintedAmount;
    }

    public void setMintedAmount(BigDecimal mintedAmount) {
        this.mintedAmount = mintedAmount;
    }

    public String getTreasuryAccountId() {
        return treasuryAccountId;
    }

    public void setTreasuryAccountId(String treasuryAccountId) {
        this.treasuryAccountId = treasuryAccountId;
    }

    public Boolean getActive() {
        return isActive;
    }

    public void setActive(Boolean active) {
        isActive = active;
    }

    public String getMetadata() {
        return metadata;
    }

    public void setMetadata(String metadata) {
        this.metadata = metadata;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}

