package com.agrilend.backend.controller;

import com.agrilend.backend.dto.common.ApiResponse;
import com.agrilend.backend.dto.offer.OfferDto;
import com.agrilend.backend.dto.order.OrderDto;
import com.agrilend.backend.dto.user.UserProfileDto;
import com.agrilend.backend.security.UserPrincipal;
import com.agrilend.backend.service.OfferService;
import com.agrilend.backend.service.OrderService;
import com.agrilend.backend.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/farmer")
@Tag(name = "Farmer", description = "API pour les agriculteurs")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasRole('FARMER')")
@CrossOrigin(origins = "*", maxAge = 3600)
public class FarmerController {

    @Autowired
    private UserService userService;

    @Autowired
    private OfferService offerService;

    @Autowired
    private OrderService orderService;

    @GetMapping("/profile")
    @Operation(summary = "Obtenir le profil agriculteur", description = "Récupère le profil de l'agriculteur connecté")
    public ResponseEntity<ApiResponse<UserProfileDto>> getProfile(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        UserProfileDto profile = userService.getUserProfile(userPrincipal.getId());
        return ResponseEntity.ok(ApiResponse.success("Profil récupéré avec succès", profile));
    }

    @PutMapping("/profile")
    @Operation(summary = "Mettre à jour le profil", description = "Met à jour le profil de l'agriculteur connecté")
    public ResponseEntity<ApiResponse<UserProfileDto>> updateProfile(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody UserProfileDto userProfileDto) {
        UserProfileDto updatedProfile = userService.updateUserProfile(userPrincipal.getId(), userProfileDto);
        return ResponseEntity.ok(ApiResponse.success("Profil mis à jour avec succès", updatedProfile));
    }

    // Gestion des offres
    @PostMapping("/offers")
    @Operation(summary = "Créer une offre", description = "Crée une nouvelle offre pour un produit existant")
    public ResponseEntity<ApiResponse<OfferDto>> createOffer(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody OfferDto offerDto) {
        OfferDto createdOffer = offerService.createOffer(userPrincipal.getId(), offerDto);
        return ResponseEntity.ok(ApiResponse.success("Offre créée avec succès", createdOffer));
    }

    @GetMapping("/offers")
    @Operation(summary = "Obtenir mes offres", description = "Récupère toutes les offres de l'agriculteur connecté")
    public ResponseEntity<ApiResponse<List<OfferDto>>> getOffers(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        List<OfferDto> offers = offerService.getOffersByFarmer(userPrincipal.getId());
        return ResponseEntity.ok(ApiResponse.success("Offres récupérées avec succès", offers));
    }

    @PutMapping("/offers/{offerId}")
    @Operation(summary = "Mettre à jour une offre", description = "Met à jour une de mes offres existantes")
    public ResponseEntity<ApiResponse<OfferDto>> updateOffer(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long offerId,
            @Valid @RequestBody OfferDto offerDto) {
        OfferDto updatedOffer = offerService.updateOffer(offerId, userPrincipal.getId(), offerDto);
        return ResponseEntity.ok(ApiResponse.success("Offre mise à jour avec succès", updatedOffer));
    }

    @DeleteMapping("/offers/{offerId}")
    @Operation(summary = "Supprimer une offre", description = "Supprime une de mes offres (si elle est en brouillon)")
    public ResponseEntity<ApiResponse<String>> deleteOffer(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long offerId) {
        offerService.deleteOffer(offerId, userPrincipal.getId());
        return ResponseEntity.ok(ApiResponse.success("Offre supprimée avec succès"));
    }

    // Consultation des commandes reçues
    @GetMapping("/orders")
    @Operation(summary = "Obtenir les commandes reçues", description = "Récupère toutes les commandes reçues par l'agriculteur")
    public ResponseEntity<ApiResponse<List<OrderDto>>> getOrders(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        List<OrderDto> orders = orderService.getOrdersByFarmer(userPrincipal.getId());
        return ResponseEntity.ok(ApiResponse.success("Commandes reçues récupérées avec succès", orders));
    }

    @GetMapping("/orders/{orderId}")
    @Operation(summary = "Obtenir une commande reçue", description = "Récupère les détails d'une commande reçue spécifique")
    public ResponseEntity<ApiResponse<OrderDto>> getOrder(@PathVariable Long orderId) {
        OrderDto order = orderService.getOrderById(orderId);
        // Optional: Add check to ensure the order belongs to this farmer
        return ResponseEntity.ok(ApiResponse.success("Commande récupérée avec succès", order));
    }
}