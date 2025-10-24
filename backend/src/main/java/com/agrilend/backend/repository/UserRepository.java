package com.agrilend.backend.repository;

import com.agrilend.backend.entity.User;
import com.agrilend.backend.entity.enums.UserRole;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    boolean existsByEmail(String email);

    List<User> findAllByRole(UserRole role);

    Page<User> findByRole(UserRole role, Pageable pageable);

    long countByIsActiveTrue();

    long countByIsActiveFalse();

    long countByEmailVerifiedFalse();

}