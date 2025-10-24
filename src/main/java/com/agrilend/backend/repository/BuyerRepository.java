package com.agrilend.backend.repository;

import com.agrilend.backend.entity.Buyer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface BuyerRepository extends JpaRepository<Buyer, Long> {

    Optional<Buyer> findByUserEmail(String email);

    long countByUser_IsActiveTrue();

}
