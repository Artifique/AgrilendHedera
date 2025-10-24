package com.agrilend.backend.repository;

import com.agrilend.backend.entity.Offer;
import com.agrilend.backend.entity.enums.OfferStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OfferRepository extends JpaRepository<Offer, Long> {

    List<Offer> findByFarmerId(Long farmerId);

    Page<Offer> findByStatus(OfferStatus status, Pageable pageable);

    List<Offer> findByStatus(OfferStatus status);

    long countByStatus(OfferStatus status);

    @Query("SELECT o FROM Offer o WHERE o.status = :status ORDER BY o.createdAt DESC")
    List<Offer> findByStatusOrderByCreatedAtDesc(@Param("status") OfferStatus status);

    @Query("SELECT o FROM Offer o WHERE o.farmer.id = :farmerId ORDER BY o.createdAt DESC")
    List<Offer> findByFarmerIdOrderByCreatedAtDesc(@Param("farmerId") Long farmerId);
}