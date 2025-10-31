package com.agrilend.backend.controller;

import com.agrilend.backend.dto.common.ApiResponse;
import com.agrilend.backend.dto.common.PageResponse;
import com.agrilend.backend.dto.offer.OfferDto;
import com.agrilend.backend.dto.order.CreateOrderRequest;
import com.agrilend.backend.dto.order.OrderDto;
import com.agrilend.backend.dto.purchase.*;
import com.agrilend.backend.dto.user.UserProfileDto;
import com.agrilend.backend.security.UserPrincipal;
import com.agrilend.backend.service.HederaService;
import com.agrilend.backend.service.HbarDepositService;
import com.agrilend.backend.service.OfferService;
import com.agrilend.backend.service.OrderService;
import com.agrilend.backend.service.UserService;
import com.agrilend.backend.service.BuyerService;
import com.agrilend.backend.dto.purchase.WarehouseReceiptDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value; // New import
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/buyer")
@Tag(name = "Buyer", description = "API pour les acheteurs")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasRole('BUYER')")
@CrossOrigin(origins = "*", maxAge = 3600)
public class BuyerController {

    @Autowired
    private UserService userService;

    @Autowired
    private OfferService offerService;

    @Autowired
    private OrderService orderService;

    @Autowired
    private HederaService hederaService;

    @Autowired
    private HbarDepositService hbarDepositService; // New dependency

    @Autowired
    private BuyerService buyerService;

    @Value("${hedera.harvest-vault.contract-id:}") // New value from application.properties
    private String harvestVaultContractId;

    @PostMapping("/deposit/prepare")
    @Operation(summary = "Préparer une transaction de dépôt HBAR dans le HarvestVault",
               description = "Génère une transaction Hedera non signée pour le dépôt de HBAR. L'acheteur doit la signer avec son portefeuille.")
    public ResponseEntity<ApiResponse<PrepareDepositResponse>> prepareHbarDeposit(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody PrepareDepositRequest request) {
        
        if (harvestVaultContractId.isEmpty()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("L'ID du contrat HarvestVault n'est pas configuré."));
        }

        // Récupérer l'ID du compte Hedera de l'acheteur
        String buyerHederaAccountId = userService.getUserProfile(userPrincipal.getId()).getHederaAccountId();
        if (buyerHederaAccountId == null || buyerHederaAccountId.isEmpty()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Votre compte Hedera n'est pas configuré. Veuillez le configurer dans votre profil."));
        }

        String unsignedTx = orderService.prepareDepositTransaction(
            request.getAmount(),
            buyerHederaAccountId,
            harvestVaultContractId
        );
        
        return ResponseEntity.ok(ApiResponse.success("Transaction de dépôt préparée", new PrepareDepositResponse(unsignedTx)));
    }

    @PostMapping("/deposit/confirm")
    @Operation(summary = "Confirmer un dépôt HBAR après signature et soumission par l'acheteur",
               description = "Le frontend appelle cet endpoint avec l'ID de transaction Hedera et le montant déposé.")
    public ResponseEntity<ApiResponse<String>> confirmHbarDeposit(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody ConfirmDepositRequest request) {
        try {
            hbarDepositService.createAndVerifyDeposit(
                userPrincipal.getId(),
                request.getHbarAmount(),
                request.getHederaTransactionId()
            );
            return ResponseEntity.ok(ApiResponse.success("Dépôt HBAR enregistré et vérification initiée."));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Erreur lors de la confirmation du dépôt HBAR: " + e.getMessage()));
        }
    }

    @GetMapping("/profile")
    @Operation(summary = "Obtenir le profil acheteur")
    public ResponseEntity<ApiResponse<UserProfileDto>> getProfile(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        UserProfileDto profile = userService.getUserProfile(userPrincipal.getId());
        return ResponseEntity.ok(ApiResponse.success("Profil récupéré avec succès", profile));
    }

    @PutMapping("/profile")
    @Operation(summary = "Mettre à jour le profil")
    public ResponseEntity<ApiResponse<UserProfileDto>> updateProfile(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody UserProfileDto userProfileDto) {
        UserProfileDto updatedProfile = userService.updateUserProfile(userPrincipal.getId(), userProfileDto);
        return ResponseEntity.ok(ApiResponse.success("Profil mis à jour avec succès", updatedProfile));
    }

    @GetMapping("/offers")
    @Operation(summary = "Obtenir les offres disponibles")
    public ResponseEntity<ApiResponse<PageResponse<OfferDto>>> getAvailableOffers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<OfferDto> offers = offerService.getApprovedOffers(pageable);
        PageResponse<OfferDto> pageResponse = new PageResponse<>(offers.getContent(), offers.getNumber(), offers.getSize(), offers.getTotalElements(), offers.getTotalPages(), offers.isFirst(), offers.isLast(), offers.isEmpty());
        return ResponseEntity.ok(ApiResponse.success("Offres récupérées avec succès", pageResponse));
    }

    @GetMapping("/offers/{offerId}")
    @Operation(summary = "Obtenir une offre")
    public ResponseEntity<ApiResponse<OfferDto>> getOffer(@PathVariable Long offerId) {
        OfferDto offer = offerService.getOfferById(offerId);
        return ResponseEntity.ok(ApiResponse.success("Offre récupérée avec succès", offer));
    }

    @PostMapping("/orders")
    @Operation(summary = "Passer une commande", description = "Crée une nouvelle commande liée à un dépôt HBAR vérifié.")
    public ResponseEntity<ApiResponse<OrderDto>> createOrder(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody CreateOrderRequest request) {
        OrderDto createdOrder = orderService.createOrder(userPrincipal.getId(), request.getHbarDepositId(), request);
        return ResponseEntity.ok(ApiResponse.success("Commande créée avec succès", createdOrder));
    }

    @GetMapping("/orders")
    @Operation(summary = "Obtenir mes commandes")
    public ResponseEntity<ApiResponse<List<OrderDto>>> getOrders(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        List<OrderDto> orders = orderService.getOrdersByBuyer(userPrincipal.getId());
        return ResponseEntity.ok(ApiResponse.success("Commandes récupérées avec succès", orders));
    }

    @GetMapping("/orders/{orderId}")
    @Operation(summary = "Obtenir une de mes commandes")
    public ResponseEntity<ApiResponse<OrderDto>> getOrder(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long orderId) {
        OrderDto order = orderService.getOrderById(orderId);
        if (!order.getBuyerId().equals(userPrincipal.getId())) {
            return ResponseEntity.status(403).body(ApiResponse.error("Accès non autorisé à cette commande"));
        }
        return ResponseEntity.ok(ApiResponse.success("Commande récupérée avec succès", order));
    }

    @PostMapping("/orders/{orderId}/confirm-delivery")
    @Operation(summary = "Confirmer la livraison")
    public ResponseEntity<ApiResponse<OrderDto>> confirmDelivery(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long orderId) {
        OrderDto order = orderService.getOrderById(orderId);
        if (!order.getBuyerId().equals(userPrincipal.getId())) {
            return ResponseEntity.status(403).body(ApiResponse.error("Accès non autorisé à cette commande"));
        }
        OrderDto updatedOrder = orderService.updateOrderStatus(orderId, com.agrilend.backend.entity.enums.OrderStatus.DELIVERED);
        return ResponseEntity.ok(ApiResponse.success("Livraison confirmée avec succès", updatedOrder));
    }

    @PostMapping("/redeem")
    @Operation(summary = "Racheter des AgriTokens contre des biens physiques",
               description = "Permet à l'acheteur d'échanger ses AgriTokens contre la marchandise correspondante. Retourne une transaction non signée à signer par l'acheteur.")
    public ResponseEntity<ApiResponse<String>> redeemAgriTokens(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody RedeemRequest request) {
        try {
            String unsignedTx = orderService.redeemAgriTokens(
                userPrincipal.getId(),
                request.getTokenId(),
                request.getAmount()
            );
            return ResponseEntity.ok(ApiResponse.success("Transaction de rachat d'AgriTokens préparée avec succès.", unsignedTx));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Erreur lors de la préparation du rachat d'AgriTokens: " + e.getMessage()));
        }
    }

    @PostMapping("/token/associate/prepare")
    @Operation(summary = "Préparer une transaction d'association de token",
               description = "Génère une transaction Hedera non signée pour associer un AgriToken au compte de l'acheteur.")
    public ResponseEntity<ApiResponse<PrepareAssociateResponse>> prepareTokenAssociate(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody PrepareAssociateRequest request) {
        
        String buyerHederaAccountId = userService.getUserProfile(userPrincipal.getId()).getHederaAccountId();
        if (buyerHederaAccountId == null || buyerHederaAccountId.isEmpty()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Votre compte Hedera n'est pas configuré. Veuillez le configurer dans votre profil."));
        }

        String unsignedTx = hederaService.prepareTokenAssociateTransaction(
            buyerHederaAccountId,
            request.getTokenId()
        );
        
        return ResponseEntity.ok(ApiResponse.success("Transaction d'association préparée", new PrepareAssociateResponse(unsignedTx)));
    }

    @GetMapping("/warehouse-receipts")
    @Operation(summary = "Obtenir les reçus d'entrepôt")
    public ResponseEntity<ApiResponse<List<WarehouseReceiptDto>>> getWarehouseReceipts() {
        List<WarehouseReceiptDto> receipts = buyerService.getWarehouseReceipts();
        return ResponseEntity.ok(ApiResponse.success("Reçus d'entrepôt récupérés avec succès", receipts));
    }
}
