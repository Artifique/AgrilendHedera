package com.agrilend.backend.controller;

import com.agrilend.backend.controller.AdminController.ApiResponse;
import com.agrilend.backend.dto.tokenization.*;
import com.agrilend.backend.service.HederaService;
import com.agrilend.backend.service.HederaSmartContractService;
import com.agrilend.backend.service.HederaDeploymentStore;
import com.hedera.hashgraph.sdk.ContractFunctionResult;
import com.hedera.hashgraph.sdk.ContractFunctionParameters;
import com.hedera.hashgraph.sdk.PrivateKey;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.ArrayList;
import java.util.List;
import com.agrilend.backend.service.HarvestTokenService;
import com.agrilend.backend.entity.HarvestToken;
import com.agrilend.backend.entity.WarehouseReceipt;
import com.agrilend.backend.repository.WarehouseReceiptRepository;

@RestController
@RequestMapping("/api/admin/hedera")
@Tag(name = "Admin Hedera", description = "Opérations Hedera pour le workflow de tokenisation de récolte")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasRole('ADMIN')")
@CrossOrigin(origins = "*", maxAge = 3600)
public class AdminHederaController {

    private static final Logger logger = LoggerFactory.getLogger(AdminHederaController.class);

    @Autowired
    private HederaService hederaService;

    @Autowired
    private HederaSmartContractService smartContractService;

    @Autowired
    private HederaDeploymentStore deploymentStore;

    @Autowired
    private HarvestTokenService harvestTokenService;

    @Autowired
    private WarehouseReceiptRepository warehouseReceiptRepository;

    @Value("${hedera.treasury.account-id:}")
    private String treasuryAccountId;

    // --- Étape 1: Configuration du Token et du Contrat ---

    @PostMapping("/token/create")
    @Operation(summary = "Créer l'AgriToken (le token qui représente la récolte)")
    public ResponseEntity<ApiResponse<HarvestTokenDto>> createHarvestToken(@Valid @RequestBody CreateTokenRequest req) {
        if (treasuryAccountId.isEmpty()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("L'ID du compte trésorier (hedera.treasury.account-id) n'est pas configuré."));
        }

        // Fetch WarehouseReceipt
        WarehouseReceipt warehouseReceipt = warehouseReceiptRepository.findById(req.getWarehouseReceiptId())
                .orElseThrow(() -> new RuntimeException("WarehouseReceipt non trouvé avec l'ID: " + req.getWarehouseReceiptId()));

        String hederaTokenId = hederaService.createFungibleToken(
                req.getTokenName(),
                req.getTokenSymbol(),
                req.getMaxSupply(),
                treasuryAccountId
        );

        // Create and save HarvestToken entity
        HarvestToken harvestToken = new HarvestToken();
        harvestToken.setHederaTokenId(hederaTokenId);
        harvestToken.setTokenName(req.getTokenName());
        harvestToken.setTokenSymbol(req.getTokenSymbol());
        harvestToken.setMaxSupply(req.getMaxSupply());
        harvestToken.setTotalSupply(BigDecimal.ZERO); // Initial supply is 0
        harvestToken.setMintedAmount(BigDecimal.ZERO); // Minted amount is 0 initially
        harvestToken.setTreasuryAccountId(treasuryAccountId);
        harvestToken.setActive(true); // Assuming active by default
        harvestToken.setWarehouseReceipt(warehouseReceipt); // Set the fetched WarehouseReceipt

        HarvestToken savedToken = harvestTokenService.saveHarvestToken(harvestToken);

        return ResponseEntity.ok(ApiResponse.success("AgriToken créé avec succès et sauvegardé localement", harvestTokenService.convertToDto(savedToken)));
    }

    @PostMapping("/vault/deploy")
    @Operation(summary = "Déployer le smart contract HarvestVault")
    public ResponseEntity<ApiResponse<String>> deployHarvestVault(@Valid @RequestBody DeployFactoryRequest req) {
        String contractId = smartContractService.deployContractFromBytecodeHex(req);
        deploymentStore.saveFactoryContractId(contractId); // Réutilisation du store pour sauvegarder l'ID du vault
        return ResponseEntity.ok(ApiResponse.success("HarvestVault déployé avec succès", contractId));
    }

    // --- Étape 2: Workflow de Tokenisation de Récolte ---

    @PostMapping("/harvest/mint")
    @Operation(summary = "Créer (minter) de nouveaux AgriTokens pour une nouvelle récolte")
    public ResponseEntity<ApiResponse<String>> mintTokens(@Valid @RequestBody MintBurnRequest req) {
        // Le montant doit être dans la plus petite unité du token (ex: pour 2 décimales, 100.50 tokens = 10050)
        String txId = hederaService.mintToken(req.getTokenId(), req.getAmount());
        return ResponseEntity.ok(ApiResponse.success("Mint des tokens réussi", txId));
    }

    @PostMapping("/harvest/pay-farmer")
    @Operation(summary = "Payer l'agriculteur en retirant les HBAR du HarvestVault")
    public ResponseEntity<ApiResponse<String>> payFarmer(@Valid @RequestBody PayFarmerRequest req) {
        String txId = hederaService.withdrawFromVault(
                req.getVaultContractId(),
                req.getAmount(),
                req.getFarmerAccountId()
        );
        return ResponseEntity.ok(ApiResponse.success("Paiement à l'agriculteur initié", txId));
    }

    // --- Étape 3: Récupération de la marchandise ---

    @PostMapping("/redeem/burn")
    @Operation(summary = "Brûler les AgriTokens d'un acheteur après qu'il ait récupéré sa marchandise")
    public ResponseEntity<ApiResponse<String>> burnTokens(@Valid @RequestBody MintBurnRequest req) {
        // Le montant est ce que l'utilisateur rend. L'accountId est le compte de l'utilisateur.
        String txId = hederaService.burnToken(req.getTokenId(), req.getAccountId(), req.getAmount());
        return ResponseEntity.ok(ApiResponse.success("Burn des tokens réussi", txId));
    }

    // --- Points d'accès utilitaires ---

    @PostMapping("/token/associate")
    @Operation(summary = "Associer un token au compte d'un utilisateur")
    public ResponseEntity<ApiResponse<String>> associateToken(@Valid @RequestBody AssociateTokenRequest req) {
        String txId = hederaService.associateTokenToAccount(req.getAccountId(), PrivateKey.fromString(req.getAccountPrivateKey()), req.getTokenId());
        return ResponseEntity.ok(ApiResponse.success("Association réussie", txId));
    }

     @PostMapping("/hcs/submit")
    @Operation(summary = "Soumettre un message au Hedera Consensus Service")
    public ResponseEntity<ApiResponse<String>> submitHcs(@Valid @RequestBody HcsSubmitRequest req) {
        String txId = hederaService.submitConsensusMessage(req.getTopicId(), req.getMessage());
        return ResponseEntity.ok(ApiResponse.success("Message HCS soumis", txId));
    }

    @GetMapping("/tokens")
    @Operation(summary = "Obtenir tous les AgriTokens", description = "Récupère la liste de tous les AgriTokens créés")
    public ResponseEntity<ApiResponse<List<HarvestTokenDto>>> getAllHarvestTokens() {
        try {
            List<HarvestToken> tokens = harvestTokenService.getAllHarvestTokens();
            return ResponseEntity.ok(ApiResponse.success("AgriTokens récupérés avec succès", harvestTokenService.convertToDtoList(tokens)));
        } catch (Exception e) {
            return ResponseEntity.<AdminController.ApiResponse<List<HarvestTokenDto>>>status(HttpStatus.BAD_REQUEST)
                .body(AdminController.ApiResponse.error("Erreur lors de la récupération des AgriTokens: " + e.getMessage()));
        }
    }

    @GetMapping("/tokens/{hederaTokenId}")
    @Operation(summary = "Obtenir un AgriToken par ID", description = "Récupère les détails d'un AgriToken spécifique par son ID Hedera")
    public ResponseEntity<ApiResponse<HarvestTokenDto>> getHarvestTokenById(@PathVariable String hederaTokenId) {
        try {
            HarvestToken token = harvestTokenService.getHarvestTokenByHederaId(hederaTokenId);
            if (token == null) {
                return ResponseEntity.<AdminController.ApiResponse<HarvestTokenDto>>status(HttpStatus.NOT_FOUND).body(AdminController.ApiResponse.error("AgriToken non trouvé"));
            }
            return ResponseEntity.ok(ApiResponse.success("AgriToken récupéré avec succès", harvestTokenService.convertToDto(token)));
        } catch (Exception e) {
            return ResponseEntity.<AdminController.ApiResponse<HarvestTokenDto>>status(HttpStatus.BAD_REQUEST)
                .body(AdminController.ApiResponse.error("Erreur lors de la récupération de l'AgriToken: " + e.getMessage()));
        }
    }
}
