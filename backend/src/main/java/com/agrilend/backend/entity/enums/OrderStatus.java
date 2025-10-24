package com.agrilend.backend.entity.enums;

public enum OrderStatus {
    PENDING,        // En attente
    IN_ESCROW,      // En séquestre
    RELEASED,       // Fonds libérés
    IN_DELIVERY,    // En cours de livraison
    DELIVERED,      // Livrée
    CANCELLED,      // Annulée
    DISPUTED        // En litige
}