package com.agrilend.backend.dto.tokenization;

import com.agrilend.backend.entity.enums.ProductUnit;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class WarehouseReceiptDto {

    private Long id;
    private Long farmerId;
    private String farmerName;
    private Long productId;
    private String productName;
    private String batchNumber;
    private BigDecimal grossWeight;
    private BigDecimal netWeight;
    private ProductUnit weightUnit;
    private LocalDateTime deliveryDate;
    private String storageLocation;
    private String qualityGrade;
    private String inspectionReport;
    private String receiptHash;
    private String auditorSignature;
    private Boolean isValidated;
    private LocalDateTime validatedAt;
    private Long validatedById;
    private String validatedByEmail;
    private Boolean tokensMinted;
    private String tokenMintTransactionId;
    private String scheduledTransactionId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Getters and Setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getFarmerId() {
        return farmerId;
    }

    public void setFarmerId(Long farmerId) {
        this.farmerId = farmerId;
    }

    public String getFarmerName() {
        return farmerName;
    }

    public void setFarmerName(String farmerName) {
        this.farmerName = farmerName;
    }

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getBatchNumber() {
        return batchNumber;
    }

    public void setBatchNumber(String batchNumber) {
        this.batchNumber = batchNumber;
    }

    public BigDecimal getGrossWeight() {
        return grossWeight;
    }

    public void setGrossWeight(BigDecimal grossWeight) {
        this.grossWeight = grossWeight;
    }

    public BigDecimal getNetWeight() {
        return netWeight;
    }

    public void setNetWeight(BigDecimal netWeight) {
        this.netWeight = netWeight;
    }

    public ProductUnit getWeightUnit() {
        return weightUnit;
    }

    public void setWeightUnit(ProductUnit weightUnit) {
        this.weightUnit = weightUnit;
    }

    public LocalDateTime getDeliveryDate() {
        return deliveryDate;
    }

    public void setDeliveryDate(LocalDateTime deliveryDate) {
        this.deliveryDate = deliveryDate;
    }

    public String getStorageLocation() {
        return storageLocation;
    }

    public void setStorageLocation(String storageLocation) {
        this.storageLocation = storageLocation;
    }

    public String getQualityGrade() {
        return qualityGrade;
    }

    public void setQualityGrade(String qualityGrade) {
        this.qualityGrade = qualityGrade;
    }

    public String getInspectionReport() {
        return inspectionReport;
    }

    public void setInspectionReport(String inspectionReport) {
        this.inspectionReport = inspectionReport;
    }

    public String getReceiptHash() {
        return receiptHash;
    }

    public void setReceiptHash(String receiptHash) {
        this.receiptHash = receiptHash;
    }

    public String getAuditorSignature() {
        return auditorSignature;
    }

    public void setAuditorSignature(String auditorSignature) {
        this.auditorSignature = auditorSignature;
    }

    public Boolean getIsValidated() {
        return isValidated;
    }

    public void setIsValidated(Boolean isValidated) {
        this.isValidated = isValidated;
    }

    public LocalDateTime getValidatedAt() {
        return validatedAt;
    }

    public void setValidatedAt(LocalDateTime validatedAt) {
        this.validatedAt = validatedAt;
    }

    public Long getValidatedById() {
        return validatedById;
    }

    public void setValidatedById(Long validatedById) {
        this.validatedById = validatedById;
    }

    public String getValidatedByEmail() {
        return validatedByEmail;
    }

    public void setValidatedByEmail(String validatedByEmail) {
        this.validatedByEmail = validatedByEmail;
    }

    public Boolean getTokensMinted() {
        return tokensMinted;
    }

    public void setTokensMinted(Boolean tokensMinted) {
        this.tokensMinted = tokensMinted;
    }

    public String getTokenMintTransactionId() {
        return tokenMintTransactionId;
    }

    public void setTokenMintTransactionId(String tokenMintTransactionId) {
        this.tokenMintTransactionId = tokenMintTransactionId;
    }

    public String getScheduledTransactionId() {
        return scheduledTransactionId;
    }

    public void setScheduledTransactionId(String scheduledTransactionId) {
        this.scheduledTransactionId = scheduledTransactionId;
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
