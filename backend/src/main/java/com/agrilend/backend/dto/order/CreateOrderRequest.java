package com.agrilend.backend.dto.order;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;

public class CreateOrderRequest {
    
    @NotNull(message = "L'offre est obligatoire")
    private Long offerId;

    @NotNull(message = "La quantité commandée est obligatoire")
    @Positive(message = "La quantité commandée doit être positive")
    private BigDecimal orderedQuantity;

    @NotBlank(message = "L'adresse de livraison est obligatoire")
    private String deliveryAddress;

    private String notes;

    public CreateOrderRequest() {}

    public CreateOrderRequest(Long offerId, BigDecimal orderedQuantity, String deliveryAddress, String notes) {
        this.offerId = offerId;
        this.orderedQuantity = orderedQuantity;
        this.deliveryAddress = deliveryAddress;
        this.notes = notes;
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
}

