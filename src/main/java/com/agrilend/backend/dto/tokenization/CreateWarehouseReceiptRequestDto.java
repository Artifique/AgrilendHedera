package com.agrilend.backend.dto.tokenization;

import com.agrilend.backend.entity.enums.ProductUnit;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;

public class CreateWarehouseReceiptRequestDto {

    @NotNull(message = "L'ID de l'agriculteur est obligatoire")
    private Long farmerId;

    @NotNull(message = "L'ID du produit est obligatoire")
    private Long productId;

    @NotBlank(message = "Le numéro de lot est obligatoire")
    private String batchNumber;

    @NotNull(message = "Le poids brut est obligatoire")
    @Positive(message = "Le poids brut doit être positif")
    private BigDecimal grossWeight;

    @NotNull(message = "Le poids net est obligatoire")
    @Positive(message = "Le poids net doit être positif")
    private BigDecimal netWeight;

    @NotNull(message = "L'unité de poids est obligatoire")
    private ProductUnit weightUnit;

    @NotBlank(message = "L'emplacement de stockage est obligatoire")
    private String storageLocation;

    @NotBlank(message = "Le grade de qualité est obligatoire")
    private String qualityGrade;

    // Getters and Setters

    public Long getFarmerId() {
        return farmerId;
    }

    public void setFarmerId(Long farmerId) {
        this.farmerId = farmerId;
    }

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
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
}
