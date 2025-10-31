package com.agrilend.backend.entity;

import com.agrilend.backend.entity.enums.DepositStatus;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Entité représentant un dépôt HBAR effectué par un acheteur dans le HarvestVault.
 */
@Entity
@Table(name = "hbar_deposits")
public class HbarDeposit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "buyer_id", nullable = false)
    private Buyer buyer;

    @Column(name = "hbar_amount", precision = 18, scale = 8, nullable = false)
    private BigDecimal hbarAmount;

    @Column(name = "hedera_transaction_id", unique = true, nullable = false)
    private String hederaTransactionId;

    @Column(name = "vault_contract_id", nullable = false)
    private String vaultContractId;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private DepositStatus status = DepositStatus.PENDING_VERIFICATION;

    @Column(name = "verification_date")
    private LocalDateTime verificationDate;

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

    public Buyer getBuyer() {
        return buyer;
    }

    public void setBuyer(Buyer buyer) {
        this.buyer = buyer;
    }

    public BigDecimal getHbarAmount() {
        return hbarAmount;
    }

    public void setHbarAmount(BigDecimal hbarAmount) {
        this.hbarAmount = hbarAmount;
    }

    public String getHederaTransactionId() {
        return hederaTransactionId;
    }

    public void setHederaTransactionId(String hederaTransactionId) {
        this.hederaTransactionId = hederaTransactionId;
    }

    public String getVaultContractId() {
        return vaultContractId;
    }

    public void setVaultContractId(String vaultContractId) {
        this.vaultContractId = vaultContractId;
    }

    public DepositStatus getStatus() {
        return status;
    }

    public void setStatus(DepositStatus status) {
        this.status = status;
    }

    public LocalDateTime getVerificationDate() {
        return verificationDate;
    }

    public void setVerificationDate(LocalDateTime verificationDate) {
        this.verificationDate = verificationDate;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return this.updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
