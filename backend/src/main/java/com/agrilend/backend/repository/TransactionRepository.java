package com.agrilend.backend.repository;

import com.agrilend.backend.entity.Transaction;
import com.agrilend.backend.entity.enums.TransactionType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {

    /**
     * Trouve une transaction par son ID Hedera
     */
    Optional<Transaction> findByHederaTransactionId(String hederaTransactionId);

    /**
     * Trouve une transaction par son schedule ID
     */
    Optional<Transaction> findByScheduleId(String scheduleId);

    /**
     * Trouve les transactions par type
     */
    List<Transaction> findByTypeOrderByCreatedAtDesc(TransactionType type);

    /**
     * Trouve les transactions par statut
     */
    List<Transaction> findByStatusOrderByCreatedAtDesc(Transaction.TransactionStatus status);

    long countByStatus(Transaction.TransactionStatus status);

    /**
     * Trouve les transactions d'une commande
     */
    List<Transaction> findByOrder_IdOrderByCreatedAtDesc(Long orderId);

    /**
     * Trouve les transactions d'un reçu d'entrepôt
     */
    @Query("SELECT t FROM Transaction t WHERE t.warehouseReceipt.id = :receiptId ORDER BY t.createdAt DESC")
    List<Transaction> findByWarehouseReceiptId(@Param("receiptId") Long receiptId);

    /**
     * Trouve les transactions d'un token de récolte
     */
    @Query("SELECT t FROM Transaction t WHERE t.harvestToken.id = :tokenId ORDER BY t.createdAt DESC")
    List<Transaction> findByHarvestTokenId(@Param("tokenId") Long tokenId);

    /**
     * Trouve les transactions par période
     */
    @Query("SELECT t FROM Transaction t WHERE t.createdAt BETWEEN :startDate AND :endDate ORDER BY t.createdAt DESC")
    List<Transaction> findByCreatedAtBetween(@Param("startDate") LocalDateTime startDate, 
                                           @Param("endDate") LocalDateTime endDate);

    /**
     * Trouve les transactions en attente
     */
    @Query("SELECT t FROM Transaction t WHERE t.status = 'PENDING' ORDER BY t.createdAt ASC")
    List<Transaction> findPendingTransactions();

    /**
     * Compte les transactions par type et statut
     */
    @Query("SELECT COUNT(t) FROM Transaction t WHERE t.type = :type AND t.status = :status")
    Long countByTypeAndStatus(@Param("type") TransactionType type, 
                             @Param("status") Transaction.TransactionStatus status);
}