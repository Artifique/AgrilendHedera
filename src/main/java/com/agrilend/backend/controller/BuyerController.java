package com.agrilend.backend.controller;

import com.agrilend.backend.dto.common.ApiResponse;
import com.agrilend.backend.dto.common.PageResponse;
import com.agrilend.backend.dto.offer.OfferDto;
import com.agrilend.backend.dto.order.CreateOrderRequest;
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
    @Operation(summary = "Passer une commande")
    public ResponseEntity<ApiResponse<OrderDto>> createOrder(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody CreateOrderRequest request) {
        OrderDto createdOrder = orderService.createOrder(userPrincipal.getId(), request);
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
}