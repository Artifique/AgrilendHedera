package com.agrilend.backend.repository;

import com.agrilend.backend.entity.HarvestToken;
import com.agrilend.backend.entity.WarehouseReceipt;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface HarvestTokenRepository extends JpaRepository<HarvestToken, Long> {

    /**
     * Trouve un token par son ID Hedera
     */
    Optional<HarvestToken> findByHederaTokenId(String hederaTokenId);

    /**
     * Trouve un token par son reçu d'entrepôt
     */
    Optional<HarvestToken> findByWarehouseReceipt(WarehouseReceipt warehouseReceipt);

    /**
     * Trouve tous les tokens actifs
     */
    List<HarvestToken> findByIsActiveTrue();

    /**
     * Trouve les tokens par compte de trésorerie
     */
    List<HarvestToken> findByTreasuryAccountId(String treasuryAccountId);

    /**
     * Trouve les tokens par symbole
     */
    List<HarvestToken> findByTokenSymbolContainingIgnoreCase(String symbol);

    /**
     * Trouve les tokens par nom
     */
    List<HarvestToken> findByTokenNameContainingIgnoreCase(String name);

    /**
     * Calcule la supply totale de tous les tokens actifs
     */
    @Query("SELECT SUM(ht.totalSupply) FROM HarvestToken ht WHERE ht.isActive = true")
    Long getTotalActiveSupply();

    /**
     * Trouve les tokens avec supply disponible pour minting
     */
    @Query("SELECT ht FROM HarvestToken ht WHERE ht.mintedAmount < ht.maxSupply AND ht.isActive = true")
    List<HarvestToken> findTokensWithAvailableSupply();

    /**
     * Vérifie si un token ID Hedera existe déjà
     */
    boolean existsByHederaTokenId(String hederaTokenId);

    /**
     * Vérifie si un symbole de token existe déjà
     */
    boolean existsByTokenSymbol(String tokenSymbol);
}

