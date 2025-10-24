package com.agrilend.backend.entity;

import com.agrilend.backend.entity.enums.OfferStatus;
import com.agrilend.backend.entity.enums.ProductionMethod;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Entité représentant une offre de produit agricole
 */
@Entity
@Table(name = "offers")
public class Offer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "farmer_id", nullable = false)
    private Farmer farmer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @NotNull
    @Positive
    @Column(name = "quantity", precision = 10, scale = 2)
    private BigDecimal availableQuantity;

    @NotNull
    @Positive
    @Column(name = "suggested_price", precision = 10, scale = 2)
    private BigDecimal suggestedUnitPrice;

    @Column(name = "harvest_date")
    private LocalDate harvestDate;

    @Column(name = "availability_date")
    private LocalDate availabilityDate;

    @Enumerated(EnumType.STRING)
    private OfferStatus status = OfferStatus.DRAFT;

    @Column(name = "admin_validated")
    private Boolean adminValidated = false;

    @Column(name = "validated_at")
    private LocalDateTime validatedAt;

    @Column(name = "final_price_farmer", precision = 10, scale = 2)
    private BigDecimal finalPriceFarmer;

    @Column(name = "final_price_buyer", precision = 10, scale = 2)
    private BigDecimal finalPriceBuyer;

    @Column(name = "rejection_reason", columnDefinition = "TEXT")
    private String rejectionReason;

    @Column(name = "quality_grade")
    private String qualityGrade;

    @Column(name = "origin_location")
    private String originLocation;

    @Enumerated(EnumType.STRING)
    @Column(name = "production_method")
    private ProductionMethod productionMethod;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // Constructeurs
    public Offer() {
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Getters et Setters
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

    public BigDecimal getAvailableQuantity() {
        return availableQuantity;
    }

    public void setAvailableQuantity(BigDecimal availableQuantity) {
        this.availableQuantity = availableQuantity;
    }

    public BigDecimal getSuggestedUnitPrice() {
        return suggestedUnitPrice;
    }

    public void setSuggestedUnitPrice(BigDecimal suggestedUnitPrice) {
        this.suggestedUnitPrice = suggestedUnitPrice;
    }

    public LocalDate getHarvestDate() {
        return harvestDate;
    }

    public void setHarvestDate(LocalDate harvestDate) {
        this.harvestDate = harvestDate;
    }

    public LocalDate getAvailabilityDate() {
        return availabilityDate;
    }

    public void setAvailabilityDate(LocalDate availabilityDate) {
        this.availabilityDate = availabilityDate;
    }

    public OfferStatus getStatus() {
        return status;
    }

    public void setStatus(OfferStatus status) {
        this.status = status;
    }

    public Boolean getAdminValidated() {
        return adminValidated;
    }

    public void setAdminValidated(Boolean adminValidated) {
        this.adminValidated = adminValidated;
    }

    public LocalDateTime getValidatedAt() {
        return validatedAt;
    }

    public void setValidatedAt(LocalDateTime validatedAt) {
        this.validatedAt = validatedAt;
    }

    public BigDecimal getFinalPriceFarmer() {
        return finalPriceFarmer;
    }

    public void setFinalPriceFarmer(BigDecimal finalPriceFarmer) {
        this.finalPriceFarmer = finalPriceFarmer;
    }

    public BigDecimal getFinalPriceBuyer() {
        return finalPriceBuyer;
    }

    public void setFinalPriceBuyer(BigDecimal finalPriceBuyer) {
        this.finalPriceBuyer = finalPriceBuyer;
    }

    public String getRejectionReason() {
        return rejectionReason;
    }

    public void setRejectionReason(String rejectionReason) {
        this.rejectionReason = rejectionReason;
    }

    public String getQualityGrade() {
        return qualityGrade;
    }

    public void setQualityGrade(String qualityGrade) {
        this.qualityGrade = qualityGrade;
    }

    public String getOriginLocation() {
        return originLocation;
    }

    public void setOriginLocation(String originLocation) {
        this.originLocation = originLocation;
    }

    public ProductionMethod getProductionMethod() {
        return productionMethod;
    }

    public void setProductionMethod(ProductionMethod productionMethod) {
        this.productionMethod = productionMethod;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
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

