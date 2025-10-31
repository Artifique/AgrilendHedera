package com.agrilend.backend.dto.tokenization;

import com.agrilend.backend.entity.enums.ProductUnit;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class HarvestTokenDto {

    private Long id;
    private String hederaTokenId;
    private String tokenName;
    private String tokenSymbol;
    private BigDecimal totalSupply;
    private BigDecimal maxSupply;
    private BigDecimal mintedAmount;
    private String treasuryAccountId;
    private Boolean isActive;
    private String metadata;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Details from WarehouseReceipt
    private Long warehouseReceiptId;
    private String warehouseReceiptBatchNumber;
    private BigDecimal warehouseReceiptNetWeight;
    private ProductUnit warehouseReceiptWeightUnit;
    private String warehouseReceiptQualityGrade;

    private String warehouseReceiptFarmerFirstName;
    private String warehouseReceiptFarmerLastName;

    // Getters and Setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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

    public Long getWarehouseReceiptId() {
        return warehouseReceiptId;
    }

    public void setWarehouseReceiptId(Long warehouseReceiptId) {
        this.warehouseReceiptId = warehouseReceiptId;
    }

    public String getWarehouseReceiptBatchNumber() {
        return warehouseReceiptBatchNumber;
    }

    public void setWarehouseReceiptBatchNumber(String warehouseReceiptBatchNumber) {
        this.warehouseReceiptBatchNumber = warehouseReceiptBatchNumber;
    }

    public BigDecimal getWarehouseReceiptNetWeight() {
        return warehouseReceiptNetWeight;
    }

    public void setWarehouseReceiptNetWeight(BigDecimal warehouseReceiptNetWeight) {
        this.warehouseReceiptNetWeight = warehouseReceiptNetWeight;
    }

    public ProductUnit getWarehouseReceiptWeightUnit() {
        return warehouseReceiptWeightUnit;
    }

    public void setWarehouseReceiptWeightUnit(ProductUnit warehouseReceiptWeightUnit) {
        this.warehouseReceiptWeightUnit = warehouseReceiptWeightUnit;
    }

    public String getWarehouseReceiptQualityGrade() {
        return warehouseReceiptQualityGrade;
    }

    public void setWarehouseReceiptQualityGrade(String warehouseReceiptQualityGrade) {
        this.warehouseReceiptQualityGrade = warehouseReceiptQualityGrade;
    }

    public String getWarehouseReceiptFarmerFirstName() {
        return warehouseReceiptFarmerFirstName;
    }

    public void setWarehouseReceiptFarmerFirstName(String warehouseReceiptFarmerFirstName) {
        this.warehouseReceiptFarmerFirstName = warehouseReceiptFarmerFirstName;
    }

    public String getWarehouseReceiptFarmerLastName() {
        return warehouseReceiptFarmerLastName;
    }

    public void setWarehouseReceiptFarmerLastName(String warehouseReceiptFarmerLastName) {
        this.warehouseReceiptFarmerLastName = warehouseReceiptFarmerLastName;
    }
}
