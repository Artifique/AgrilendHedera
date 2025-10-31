package com.agrilend.backend.repository;

import com.agrilend.backend.entity.HbarDeposit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HbarDepositRepository extends JpaRepository<HbarDeposit, Long> {
    // Custom queries can be added here if needed
}
