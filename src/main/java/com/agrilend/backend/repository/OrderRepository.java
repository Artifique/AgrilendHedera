package com.agrilend.backend.repository;

import com.agrilend.backend.entity.Order;
import com.agrilend.backend.entity.enums.OrderStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {

    List<Order> findByBuyerId(Long buyerId);

    List<Order> findByOfferFarmerId(Long farmerId);

    Page<Order> findByStatus(OrderStatus status, Pageable pageable);

    List<Order> findByStatus(OrderStatus status);

    long countByStatus(OrderStatus status);

    @Query("SELECT o FROM Order o WHERE o.status = :status ORDER BY o.createdAt DESC")
    List<Order> findByStatusOrderByCreatedAtDesc(@Param("status") OrderStatus status);

    @Query("SELECT o FROM Order o WHERE o.status = 'IN_ESCROW' AND o.escrowEndDate < :currentDate")
    List<Order> findExpiredEscrowOrders(@Param("currentDate") LocalDateTime currentDate);

    @Query("SELECT SUM(o.totalAmount) FROM Order o WHERE o.createdAt >= :dateTime")
    BigDecimal sumTotalAmountByCreatedAtAfter(@Param("dateTime") LocalDateTime dateTime);

    @Query("SELECT SUM(o.totalAmount) FROM Order o WHERE o.createdAt BETWEEN :startDate AND :endDate")
    BigDecimal sumTotalAmountByCreatedAtBetween(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    @Query("SELECT p.category, SUM(o.totalAmount) FROM Order o JOIN o.offer off JOIN off.product p GROUP BY p.category")
    List<Object[]> sumTotalAmountByCategory();

}