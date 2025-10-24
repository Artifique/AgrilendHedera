package com.agrilend.backend.repository;

import com.agrilend.backend.entity.Farmer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface FarmerRepository extends JpaRepository<Farmer, Long> {

    Optional<Farmer> findByUserId(Long userId);

    Optional<Farmer> findByUser_Id(Long userId);

    Optional<Farmer> findByUser_Email(String email);

    long  countByUser_IsActiveTrue();

}