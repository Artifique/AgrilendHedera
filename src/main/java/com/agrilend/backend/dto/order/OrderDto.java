package com.agrilend.backend.dto.order;

import com.agrilend.backend.entity.enums.OrderStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class OrderDto {
    
    private Long id;
    private String orderNumber;
    private Long offerId;
    private BigDecimal orderedQuantity;
    private BigDecimal unitPrice;
    private BigDecimal totalAmount;
    private OrderStatus status;
    private String deliveryAddress;
    private String notes;
    
    // Informations de l'offre
    private String productName;
    private String productUnit;
    private Long farmerId;
    private String farmerName;
    
    // Informations de l'acheteur
    private Long buyerId;
    private String buyerName;
    private String buyerEmail;
    
    // Informations Hedera
    private String escrowTransactionId;
    private LocalDateTime escrowStartDate;
    private LocalDateTime escrowEndDate;
    
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Getters and Setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getOrderNumber() {
        return orderNumber;
    }

    public void setOrderNumber(String orderNumber) {
        this.orderNumber = orderNumber;
    }

    public Long getOfferId() {
        return offerId;
    }

    public void setOfferId(Long offerId) {
        this.offerId = offerId;
    }

    public BigDecimal getOrderedQuantity() {
        return orderedQuantity;
    }

    public void setOrderedQuantity(BigDecimal orderedQuantity) {
        this.orderedQuantity = orderedQuantity;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public OrderStatus getStatus() {
        return status;
    }

    public void setStatus(OrderStatus status) {
        this.status = status;
    }

    public String getDeliveryAddress() {
        return deliveryAddress;
    }

    public void setDeliveryAddress(String deliveryAddress) {
        this.deliveryAddress = deliveryAddress;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getProductUnit() {
        return productUnit;
    }

    public void setProductUnit(String productUnit) {
        this.productUnit = productUnit;
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

    public Long getBuyerId() {
        return buyerId;
    }

    public void setBuyerId(Long buyerId) {
        this.buyerId = buyerId;
    }

    public String getBuyerName() {
        return buyerName;
    }

    public void setBuyerName(String buyerName) {
        this.buyerName = buyerName;
    }

    public String getBuyerEmail() {
        return buyerEmail;
    }

    public void setBuyerEmail(String buyerEmail) {
        this.buyerEmail = buyerEmail;
    }

    public String getEscrowTransactionId() {
        return escrowTransactionId;
    }

    public void setEscrowTransactionId(String escrowTransactionId) {
        this.escrowTransactionId = escrowTransactionId;
    }

    public LocalDateTime getEscrowStartDate() {
        return escrowStartDate;
    }

    public void setEscrowStartDate(LocalDateTime escrowStartDate) {
        this.escrowStartDate = escrowStartDate;
    }

    public LocalDateTime getEscrowEndDate() {
        return escrowEndDate;
    }

    public void setEscrowEndDate(LocalDateTime escrowEndDate) {
        this.escrowEndDate = escrowEndDate;
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

