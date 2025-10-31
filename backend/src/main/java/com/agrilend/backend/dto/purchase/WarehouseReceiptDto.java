package com.agrilend.backend.dto.purchase;

import com.agrilend.backend.entity.enums.ProductUnit;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class WarehouseReceiptDto {

    private Long id;
    private String farmerName;
    private String productName;
    private String batchNumber;
    private BigDecimal netWeight;
    private ProductUnit weightUnit;
    private LocalDateTime deliveryDate;
    private String storageLocation;
    private String qualityGrade;
    private Boolean isValidated;
    private Boolean tokensMinted;

    public WarehouseReceiptDto() {
    }

    public WarehouseReceiptDto(Long id, String farmerName, String productName, String batchNumber, BigDecimal netWeight, ProductUnit weightUnit, LocalDateTime deliveryDate, String storageLocation, String qualityGrade, Boolean isValidated, Boolean tokensMinted) {
        this.id = id;
        this.farmerName = farmerName;
        this.productName = productName;
        this.batchNumber = batchNumber;
        this.netWeight = netWeight;
        this.weightUnit = weightUnit;
        this.deliveryDate = deliveryDate;
        this.storageLocation = storageLocation;
        this.qualityGrade = qualityGrade;
        this.isValidated = isValidated;
        this.tokensMinted = tokensMinted;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getFarmerName() {
        return farmerName;
    }

    public void setFarmerName(String farmerName) {
        this.farmerName = farmerName;
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

    public Boolean getValidated() {
        return isValidated;
    }

    public void setValidated(Boolean validated) {
        isValidated = validated;
    }

    public Boolean getTokensMinted() {
        return tokensMinted;
    }

    public void setTokensMinted(Boolean tokensMinted) {
        this.tokensMinted = tokensMinted;
    }
}
