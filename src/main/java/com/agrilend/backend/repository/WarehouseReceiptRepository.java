package com.agrilend.backend.repository;

import com.agrilend.backend.entity.WarehouseReceipt;
import com.agrilend.backend.entity.Farmer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface WarehouseReceiptRepository extends JpaRepository<WarehouseReceipt, Long> {

    /**
     * Trouve un reçu par son numéro de lot
     */
    Optional<WarehouseReceipt> findByBatchNumber(String batchNumber);

    /**
     * Trouve tous les reçus d'un agriculteur
     */
    List<WarehouseReceipt> findByFarmerOrderByDeliveryDateDesc(Farmer farmer);

    /**
     * Trouve les reçus validés mais pas encore tokenisés
     */
    @Query("SELECT wr FROM WarehouseReceipt wr WHERE wr.isValidated = true AND wr.tokensMinted = false")
    List<WarehouseReceipt> findValidatedButNotTokenized();

    /**
     * Trouve les reçus en attente de validation
     */
    @Query("SELECT wr FROM WarehouseReceipt wr WHERE wr.isValidated = false ORDER BY wr.deliveryDate ASC")
    List<WarehouseReceipt> findPendingValidation();

    /**
     * Trouve les reçus par période de livraison
     */
    @Query("SELECT wr FROM WarehouseReceipt wr WHERE wr.deliveryDate BETWEEN :startDate AND :endDate ORDER BY wr.deliveryDate DESC")
    List<WarehouseReceipt> findByDeliveryDateBetween(@Param("startDate") LocalDateTime startDate, 
                                                     @Param("endDate") LocalDateTime endDate);

    /**
     * Trouve les reçus par produit
     */
    @Query("SELECT wr FROM WarehouseReceipt wr WHERE wr.product.id = :productId ORDER BY wr.deliveryDate DESC")
    List<WarehouseReceipt> findByProductId(@Param("productId") Long productId);

    /**
     * Compte les reçus validés par agriculteur
     */
    @Query("SELECT COUNT(wr) FROM WarehouseReceipt wr WHERE wr.farmer = :farmer AND wr.isValidated = true")
    Long countValidatedReceiptsByFarmer(@Param("farmer") Farmer farmer);

    /**
     * Vérifie si un numéro de lot existe déjà
     */
    boolean existsByBatchNumber(String batchNumber);

    /**
     * Trouve un reçu par son schedule ID
     */
    Optional<WarehouseReceipt> findByScheduledTransactionId(String scheduledTransactionId);
}

