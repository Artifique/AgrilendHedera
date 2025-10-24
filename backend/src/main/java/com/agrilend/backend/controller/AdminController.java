package com.agrilend.backend.controller;

import com.agrilend.backend.dto.common.ApiResponse;
import com.agrilend.backend.dto.common.PageResponse;
import com.agrilend.backend.dto.dashboard.DashboardStatsDto;
import com.agrilend.backend.dto.offer.OfferDto;
import com.agrilend.backend.dto.order.OrderDto;
import com.agrilend.backend.dto.product.ProductDto;
import com.agrilend.backend.dto.tokenization.CreateWarehouseReceiptRequestDto;
import com.agrilend.backend.dto.tokenization.TokenDistributionDto;
import com.agrilend.backend.dto.tokenization.ValidateWarehouseReceiptRequestDto;
import com.agrilend.backend.dto.user.UserProfileDto;
import com.agrilend.backend.entity.User;
import com.agrilend.backend.entity.enums.OrderStatus;
import com.agrilend.backend.security.UserPrincipal;
import com.agrilend.backend.service.*;
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

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@Tag(name = "Admin", description = "API d'administration")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasRole('ADMIN')")
@CrossOrigin(origins = "*", maxAge = 3600)
public class AdminController {

    @Autowired
    private UserService userService;

    @Autowired
    private OfferService offerService;

    @Autowired
    private OrderService orderService;

    @Autowired
    private ProductService productService;

    @Autowired
    private TokenizationService tokenizationService;

    @Autowired
    private AdminDashboardService adminDashboardService;

    // Gestion des utilisateurs
    @GetMapping("/users")
    @Operation(summary = "Obtenir tous les utilisateurs", description = "Récupère la liste paginée de tous les utilisateurs")
    public ResponseEntity<ApiResponse<PageResponse<UserProfileDto>>> getAllUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        System.out.println("DEBUG: getAllUsers endpoint hit!");
        Sort sort = sortDir.equalsIgnoreCase("desc") ?
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);

        Page<UserProfileDto> users = userService.getAllUsers(pageable);

        PageResponse<UserProfileDto> pageResponse = new PageResponse<>(
            users.getContent(),
            users.getNumber(),
            users.getSize(),
            users.getTotalElements(),
            users.getTotalPages(),
            users.isFirst(),
            users.isLast(),
            users.isEmpty()
        );

        return ResponseEntity.ok(ApiResponse.success("Utilisateurs récupérés avec succès", pageResponse));
    }

    @GetMapping("/users/{userId}")
    @Operation(summary = "Obtenir un utilisateur", description = "Récupère les détails d'un utilisateur spécifique")
    public ResponseEntity<ApiResponse<UserProfileDto>> getUser(@PathVariable Long userId) {
        UserProfileDto user = userService.getUserProfile(userId);
        return ResponseEntity.ok(ApiResponse.success("Utilisateur récupéré avec succès", user));
    }

    @PostMapping("/users/{userId}/enable")
    @Operation(summary = "Activer un utilisateur", description = "Active un compte utilisateur")
    public ResponseEntity<ApiResponse<String>> enableUser(@PathVariable Long userId) {
        userService.enableUser(userId);
        return ResponseEntity.ok(ApiResponse.success("Utilisateur activé avec succès"));
    }

    @PostMapping("/users/{userId}/disable")
    @Operation(summary = "Désactiver un utilisateur", description = "Désactive un compte utilisateur")
    public ResponseEntity<ApiResponse<String>> disableUser(@PathVariable Long userId) {
        userService.disableUser(userId);
        return ResponseEntity.ok(ApiResponse.success("Utilisateur désactivé avec succès"));
    }

    @PutMapping("/users/{userId}/profile")
    @Operation(summary = "Mettre à jour le profil d'un utilisateur (Admin)", description = "Met à jour le profil de n'importe quel utilisateur via son ID")
    public ResponseEntity<ApiResponse<UserProfileDto>> updateUserProfile(
            @PathVariable Long userId,
            @Valid @RequestBody UserProfileDto userProfileDto) {
        System.out.println("DEBUG: updateUserProfile endpoint hit for userId: " + userId);
        UserProfileDto updatedProfile = userService.updateUserProfile(userId, userProfileDto);
        return ResponseEntity.ok(ApiResponse.success("Profil utilisateur mis à jour avec succès", updatedProfile));
    }

    // Gestion des produits
    @PostMapping("/products")
    @Operation(summary = "Créer un nouveau produit", description = "Crée un nouveau produit dans le catalogue")
    public ResponseEntity<ApiResponse<ProductDto>> createProduct(@Valid @RequestBody ProductDto productDto) {
        ProductDto createdProduct = productService.createProduct(productDto);
        return ResponseEntity.ok(ApiResponse.success("Produit créé avec succès", createdProduct));
    }

    @PutMapping("/products/{productId}")
    @Operation(summary = "Mettre à jour un produit", description = "Met à jour un produit existant dans le catalogue")
    public ResponseEntity<ApiResponse<ProductDto>> updateProduct(
            @PathVariable Long productId,
            @Valid @RequestBody ProductDto productDto) {
        ProductDto updatedProduct = productService.updateProduct(productId, productDto);
        return ResponseEntity.ok(ApiResponse.success("Produit mis à jour avec succès", updatedProduct));
    }

    @PostMapping("/products/{productId}/deactivate")
    @Operation(summary = "Désactiver un produit", description = "Désactive un produit du catalogue (ne le supprime pas)")
    public ResponseEntity<ApiResponse<String>> deactivateProduct(@PathVariable Long productId) {
        productService.deactivateProduct(productId);
        return ResponseEntity.ok(ApiResponse.success("Produit désactivé avec succès"));
    }

    @PostMapping("/products/{productId}/activate")
    @Operation(summary = "Activer un produit", description = "Active un produit du catalogue")
    public ResponseEntity<ApiResponse<String>> activateProduct(@PathVariable Long productId) {
        productService.activateProduct(productId);
        return ResponseEntity.ok(ApiResponse.success("Produit activé avec succès"));
    }

    @GetMapping("/products/{productId}")
    @Operation(summary = "Obtenir un produit par ID", description = "Récupère les détails d'un produit spécifique")
    public ResponseEntity<ApiResponse<ProductDto>> getProductById(@PathVariable Long productId) {
        ProductDto product = productService.getProductById(productId);
        return ResponseEntity.ok(ApiResponse.success("Produit récupéré avec succès", product));
    }

    @GetMapping("/products")
    @Operation(summary = "Obtenir tous les produits", description = "Récupère la liste paginée de tous les produits")
    public ResponseEntity<ApiResponse<PageResponse<ProductDto>>> getAllProducts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        Sort sort = sortDir.equalsIgnoreCase("desc") ?
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);

        Page<ProductDto> products = productService.getAllProducts(pageable);

        PageResponse<ProductDto> pageResponse = new PageResponse<>(
            products.getContent(),
            products.getNumber(),
            products.getSize(),
            products.getTotalElements(),
            products.getTotalPages(),
            products.isFirst(),
            products.isLast(),
            products.isEmpty()
        );

        return ResponseEntity.ok(ApiResponse.success("Produits récupérés avec succès", pageResponse));
    }

    @GetMapping("/products/search")
    @Operation(summary = "Rechercher des produits", description = "Recherche des produits par nom ou catégorie")
    public ResponseEntity<ApiResponse<PageResponse<ProductDto>>> searchProducts(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<ProductDto> products = productService.searchProducts(keyword, pageable);

        PageResponse<ProductDto> pageResponse = new PageResponse<>(
            products.getContent(),
            products.getNumber(),
            products.getSize(),
            products.getTotalElements(),
            products.getTotalPages(),
            products.isFirst(),
            products.isLast(),
            products.isEmpty()
        );
        return ResponseEntity.ok(ApiResponse.success("Produits trouvés avec succès", pageResponse));
    }

    // Gestion des offres
    @GetMapping("/offers")
    @Operation(summary = "Obtenir toutes les offres", description = "Récupère la liste paginée de toutes les offres")
    public ResponseEntity<ApiResponse<PageResponse<OfferDto>>> getAllOffers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        Sort sort = sortDir.equalsIgnoreCase("desc") ?
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);

        Page<OfferDto> offers = offerService.getAllOffers(pageable);

        PageResponse<OfferDto> pageResponse = new PageResponse<>(
            offers.getContent(),
            offers.getNumber(),
            offers.getSize(),
            offers.getTotalElements(),
            offers.getTotalPages(),
            offers.isFirst(),
            offers.isLast(),
            offers.isEmpty()
        );

        return ResponseEntity.ok(ApiResponse.success("Offres récupérées avec succès", pageResponse));
    }

    @GetMapping("/offers/pending")
    @Operation(summary = "Obtenir les offres en attente", description = "Récupère les offres en attente de validation")
    public ResponseEntity<ApiResponse<PageResponse<OfferDto>>> getPendingOffers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());

        Page<OfferDto> offers = offerService.getPendingOffers(pageable);

        PageResponse<OfferDto> pageResponse = new PageResponse<>(
            offers.getContent(),
            offers.getNumber(),
            offers.getSize(),
            offers.getTotalElements(),
            offers.getTotalPages(),
            offers.isFirst(),
            offers.isLast(),
            offers.isEmpty()
        );

        return ResponseEntity.ok(ApiResponse.success("Offres en attente récupérées avec succès", pageResponse));
    }

    @PostMapping("/offers/{offerId}/approve")
    @Operation(summary = "Approuver une offre", description = "Approuve une offre et calcule le prix final")
    public ResponseEntity<ApiResponse<OfferDto>> approveOffer(@PathVariable Long offerId) {
        OfferDto approvedOffer = offerService.approveOffer(offerId);
        return ResponseEntity.ok(ApiResponse.success("Offre approuvée avec succès", approvedOffer));
    }

    @PostMapping("/offers/{offerId}/reject")
    @Operation(summary = "Rejeter une offre", description = "Rejette une offre avec une raison")
    public ResponseEntity<ApiResponse<OfferDto>> rejectOffer(
            @PathVariable Long offerId,
            @RequestParam String reason) {
        OfferDto rejectedOffer = offerService.rejectOffer(offerId, reason);
        return ResponseEntity.ok(ApiResponse.success("Offre rejetée avec succès", rejectedOffer));
    }

    // Gestion des commandes
    @GetMapping("/orders")
    @Operation(summary = "Obtenir toutes les commandes", description = "Récupère la liste paginée de toutes les commandes")
    public ResponseEntity<ApiResponse<PageResponse<OrderDto>>> getAllOrders(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        Sort sort = sortDir.equalsIgnoreCase("desc") ?
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);

        Page<OrderDto> orders = orderService.getAllOrders(pageable);

        PageResponse<OrderDto> pageResponse = new PageResponse<>(
            orders.getContent(),
            orders.getNumber(),
            orders.getSize(),
            orders.getTotalElements(),
            orders.getTotalPages(),
            orders.isFirst(),
            orders.isLast(),
            orders.isEmpty()
        );

        return ResponseEntity.ok(ApiResponse.success("Commandes récupérées avec succès", pageResponse));
    }

    @GetMapping("/orders/{orderId}")
    @Operation(summary = "Obtenir une commande", description = "Récupère les détails d'une commande spécifique")
    public ResponseEntity<ApiResponse<OrderDto>> getOrder(@PathVariable Long orderId) {
        OrderDto order = orderService.getOrderById(orderId);
        return ResponseEntity.ok(ApiResponse.success("Commande récupérée avec succès", order));
    }

    @PostMapping("/orders/{orderId}/status")
    @Operation(summary = "Mettre à jour le statut d'une commande", description = "Change le statut d'une commande")
    public ResponseEntity<ApiResponse<OrderDto>> updateOrderStatus(
            @PathVariable Long orderId,
            @RequestParam OrderStatus status) {
        OrderDto updatedOrder = orderService.updateOrderStatus(orderId, status);
        return ResponseEntity.ok(ApiResponse.success("Statut de commande mis à jour avec succès", updatedOrder));
    }

    @PostMapping("/orders/{orderId}/release-escrow")
    @Operation(summary = "Libérer le séquestre", description = "Libère les fonds en séquestre pour une commande")
    public ResponseEntity<ApiResponse<OrderDto>> releaseEscrow(@PathVariable Long orderId) {
        OrderDto updatedOrder = orderService.releaseEscrow(orderId);
        return ResponseEntity.ok(ApiResponse.success("Séquestre libéré avec succès", updatedOrder));
    }

    // =================== Dashboard ===================
    @GetMapping("/dashboard")
    @Operation(summary = "Obtenir les statistiques du dashboard", description = "Récupère les statistiques globales pour l'administration")
    public ResponseEntity<ApiResponse<DashboardStatsDto>> getDashboardStats() {
        DashboardStatsDto stats = adminDashboardService.getDashboardStats();
        return ResponseEntity.ok(ApiResponse.success("Statistiques du dashboard récupérées avec succès", stats));
    }

    @GetMapping("/dashboard/revenue/daily")
    @Operation(summary = "Revenu quotidien", description = "Récupère le revenu pour un jour spécifique")
    public ResponseEntity<ApiResponse<Map<LocalDate, BigDecimal>>> getDailyRevenue(
            @RequestParam("date") String dateStr) {
        LocalDate date = LocalDate.parse(dateStr);
        Map<LocalDate, BigDecimal> revenue = adminDashboardService.getDailyRevenue(date);
        return ResponseEntity.ok(ApiResponse.success("Revenu quotidien récupéré avec succès", revenue));
    }

    @GetMapping("/dashboard/revenue/monthly")
    @Operation(summary = "Revenu mensuel", description = "Récupère le revenu pour un mois spécifique")
    public ResponseEntity<ApiResponse<Map<String, BigDecimal>>> getMonthlyRevenue(
            @RequestParam("year") int year,
            @RequestParam("month") int month) {
        System.out.println("DEBUG: getMonthlyRevenue endpoint hit for year: " + year + ", month: " + month);
        Map<String, BigDecimal> revenue = adminDashboardService.getMonthlyRevenue(year, month);
        return ResponseEntity.ok(ApiResponse.success("Revenu mensuel récupéré avec succès", revenue));
    }

    @GetMapping("/dashboard/revenue/yearly")
    @Operation(summary = "Revenu annuel", description = "Récupère le revenu pour une année spécifique")
    public ResponseEntity<ApiResponse<Map<String, BigDecimal>>> getYearlyRevenue(
            @RequestParam("year") int year) {
        Map<String, BigDecimal> revenue = adminDashboardService.getYearlyRevenue(year);
        return ResponseEntity.ok(ApiResponse.success("Revenu annuel récupéré avec succès", revenue));
    }

    @GetMapping("/dashboard/revenue/category")
    @Operation(summary = "Revenu par catégorie", description = "Récupère le revenu agrégé par catégorie de produit")
    public ResponseEntity<ApiResponse<Map<String, BigDecimal>>> getRevenueByCategory() {
        Map<String, BigDecimal> revenueByCategory = adminDashboardService.getRevenueByCategory();
        return ResponseEntity.ok(ApiResponse.success("Revenu par catégorie récupéré avec succès", revenueByCategory));
    }

    @GetMapping("/dashboard/revenue/last7days")
    @Operation(summary = "Revenu des 7 derniers jours", description = "Récupère le revenu pour les 7 derniers jours")
    public ResponseEntity<ApiResponse<Map<LocalDate, BigDecimal>>> getRevenueLast7Days() {
        Map<LocalDate, BigDecimal> revenue = adminDashboardService.getRevenueLast7Days();
        return ResponseEntity.ok(ApiResponse.success("Revenu des 7 derniers jours récupéré avec succès", revenue));
    }

    @GetMapping("/dashboard/revenue/last30days")
    @Operation(summary = "Revenu des 30 derniers jours", description = "Récupère le revenu pour les 30 derniers jours")
    public ResponseEntity<ApiResponse<Map<LocalDate, BigDecimal>>> getRevenueLast30Days() {
        Map<LocalDate, BigDecimal> revenue = adminDashboardService.getRevenueLast30Days();
        return ResponseEntity.ok(ApiResponse.success("Revenu des 30 derniers jours récupéré avec succès", revenue));
    }

    @GetMapping("/dashboard/revenue/last3months")
    @Operation(summary = "Revenu des 3 derniers mois", description = "Récupère le revenu pour les 3 derniers mois")
    public ResponseEntity<ApiResponse<Map<String, BigDecimal>>> getRevenueLast3Months() {
        Map<String, BigDecimal> revenue = adminDashboardService.getRevenueLast3Months();
        return ResponseEntity.ok(ApiResponse.success("Revenu des 3 derniers mois récupéré avec succès", revenue));
    }

    @GetMapping("/dashboard/revenue/lastyear")
    @Operation(summary = "Revenu de la dernière année", description = "Récupère le revenu pour la dernière année (12 derniers mois)")
    public ResponseEntity<ApiResponse<Map<String, BigDecimal>>> getRevenueLastYear() {
        Map<String, BigDecimal> revenue = adminDashboardService.getRevenueLastYear();
        return ResponseEntity.ok(ApiResponse.success("Revenu de la dernière année récupéré avec succès", revenue));
    }


}
