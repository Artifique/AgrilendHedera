package com.agrilend.backend.entity;

import com.agrilend.backend.entity.enums.ProductUnit;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Reçu d'entrepôt pour la tokenisation des récoltes
 */
@Entity
@Table(name = "warehouse_receipts")
public class WarehouseReceipt {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "farmer_id", nullable = false)
    private Farmer farmer;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @NotNull
    @Column(name = "batch_number", unique = true, nullable = false)
    private String batchNumber;

    @NotNull
    @Positive
    @Column(name = "gross_weight", nullable = false, precision = 15, scale = 2)
    private BigDecimal grossWeight;

    @NotNull
    @Positive
    @Column(name = "net_weight", nullable = false, precision = 15, scale = 2)
    private BigDecimal netWeight;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "weight_unit", nullable = false)
    private ProductUnit weightUnit;

    @NotNull
    @Column(name = "delivery_date", nullable = false)
    private LocalDateTime deliveryDate;

    @Column(name = "storage_location")
    private String storageLocation;

    @Column(name = "quality_grade")
    private String qualityGrade;

    @Column(name = "inspection_report", columnDefinition = "TEXT")
    private String inspectionReport;

    @Column(name = "receipt_hash")
    private String receiptHash;

    @Column(name = "auditor_signature")
    private String auditorSignature;

    @Column(name = "is_validated", nullable = false)
    private Boolean isValidated = false;

    @Column(name = "validated_at")
    private LocalDateTime validatedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "validated_by")
    private User validatedBy;

    @Column(name = "tokens_minted", nullable = false)
    private Boolean tokensMinted = false;

    @Column(name = "token_mint_transaction_id")
    private String tokenMintTransactionId;

    @Column(name = "scheduled_transaction_id")
    private String scheduledTransactionId;

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

    public Farmer getFarmer() {
        return farmer;
    }

    public void setFarmer(Farmer farmer) {
        this.farmer = farmer;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
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

    public Boolean getValidated() {
        return isValidated;
    }

    public void setValidated(Boolean validated) {
        isValidated = validated;
    }

    public LocalDateTime getValidatedAt() {
        return validatedAt;
    }

    public void setValidatedAt(LocalDateTime validatedAt) {
        this.validatedAt = validatedAt;
    }

    public User getValidatedBy() {
        return validatedBy;
    }

    public void setValidatedBy(User validatedBy) {
        this.validatedBy = validatedBy;
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

