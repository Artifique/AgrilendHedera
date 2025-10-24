package com.agrilend.backend.repository;

import com.agrilend.backend.entity.Delivery;
import com.agrilend.backend.entity.enums.DeliveryStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface DeliveryRepository extends JpaRepository<Delivery, Long> {

    long countByDeliveryStatus(DeliveryStatus status);

    long countByDeliveryStatusAndCreatedAtBetween(DeliveryStatus status, LocalDateTime startDate, LocalDateTime endDate);

    List<Delivery> findByDeliveryStatusAndCreatedAtBetween(DeliveryStatus status, LocalDateTime startDate, LocalDateTime endDate);

    // count() is inherited from JpaRepository

}