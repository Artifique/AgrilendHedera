package com.agrilend.backend.controller;

import com.agrilend.backend.dto.common.ApiResponse;
import com.agrilend.backend.dto.user.LinkHederaAccountRequest;
import com.agrilend.backend.dto.user.UserProfileDto;
import com.agrilend.backend.security.UserPrincipal;
import com.agrilend.backend.service.UserService;
import com.agrilend.backend.service.HederaService;
import com.agrilend.backend.service.HederaService.HederaAccountInfo;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

@RestController
@RequestMapping("/api/user")
@Tag(name = "User Management", description = "API de gestion des utilisateurs")
@SecurityRequirement(name = "bearerAuth")
@CrossOrigin(origins = "*", maxAge = 3600)
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private HederaService hederaService;

    @GetMapping("/profile")
    @Operation(summary = "Obtenir le profil utilisateur", description = "Récupère le profil de l'utilisateur connecté")
    public ResponseEntity<ApiResponse<UserProfileDto>> getUserProfile(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        try {
            UserProfileDto profile = userService.getUserProfile(userPrincipal.getId());
            return ResponseEntity.ok(ApiResponse.success("Profil récupéré avec succès", profile));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Erreur lors de la récupération du profil: " + e.getMessage()));
        }
    }

    @PutMapping("/profile")
    @Operation(summary = "Mettre à jour le profil", description = "Met à jour le profil de l'utilisateur connecté")
    public ResponseEntity<ApiResponse<UserProfileDto>> updateUserProfile(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody UserProfileDto userProfileDto) {
        try {
            UserProfileDto updatedProfile = userService.updateUserProfile(userPrincipal.getId(), userProfileDto);
            return ResponseEntity.ok(ApiResponse.success("Profil mis à jour avec succès", updatedProfile));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Erreur lors de la mise à jour du profil: " + e.getMessage()));
        }
    }

    @PostMapping("/change-password")
    @Operation(summary = "Changer le mot de passe", description = "Change le mot de passe de l'utilisateur connecté")
    public ResponseEntity<ApiResponse<String>> changePassword(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestParam String currentPassword,
            @RequestParam String newPassword) {
        try {
            userService.changePassword(userPrincipal.getId(), currentPassword, newPassword);
            return ResponseEntity.ok(ApiResponse.success("Mot de passe changé avec succès"));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Erreur lors du changement de mot de passe: " + e.getMessage()));
        }
    }

    @GetMapping("/profile/{userId}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Obtenir un profil utilisateur (Admin)", description = "Récupère le profil d'un utilisateur spécifique (Admin uniquement)")
    public ResponseEntity<ApiResponse<UserProfileDto>> getUserProfileById(@PathVariable Long userId) {
        try {
            UserProfileDto profile = userService.getUserProfile(userId);
            return ResponseEntity.ok(ApiResponse.success("Profil récupéré avec succès", profile));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Erreur lors de la récupération du profil: " + e.getMessage()));
        }
    }

    @PostMapping("/enable/{userId}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Activer un utilisateur (Admin)", description = "Active un compte utilisateur (Admin uniquement)")
    public ResponseEntity<ApiResponse<String>> enableUser(@PathVariable Long userId) {
        try {
            userService.enableUser(userId);
            return ResponseEntity.ok(ApiResponse.success("Utilisateur activé avec succès"));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Erreur lors de l'activation: " + e.getMessage()));
        }
    }

    @PostMapping("/disable/{userId}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Désactiver un utilisateur (Admin)", description = "Désactive un compte utilisateur (Admin uniquement)")
    public ResponseEntity<ApiResponse<String>> disableUser(@PathVariable Long userId) {
        try {
            userService.disableUser(userId);
            return ResponseEntity.ok(ApiResponse.success("Utilisateur désactivé avec succès"));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Erreur lors de la désactivation: " + e.getMessage()));
        }
    }

    @PostMapping("/link-hedera-account")
    @Operation(summary = "Lier un compte Hedera existant", description = "Permet à l'utilisateur de lier son ID de compte Hedera existant à son profil.")
    public ResponseEntity<ApiResponse<String>> linkHederaAccount(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody LinkHederaAccountRequest request) {
        try {
            userService.linkHederaAccount(userPrincipal.getId(), request.getHederaAccountId());
            return ResponseEntity.ok(ApiResponse.success("Compte Hedera lié avec succès."));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Erreur lors de la liaison du compte Hedera: " + e.getMessage()));
        }
    }

    @PostMapping("/create-hedera-account")
    @Operation(summary = "Créer un nouveau compte Hedera", description = "Génère un nouveau compte Hedera et le lie au profil de l'utilisateur. Retourne la clé privée (à sauvegarder par l'utilisateur).")
    public ResponseEntity<ApiResponse<HederaAccountInfo>> createHederaAccount(
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        try {
            // Créer le compte Hedera avec un solde initial de 0 HBAR
            HederaAccountInfo newAccountInfo = hederaService.createAccount(BigDecimal.ZERO);

            // Lier l'ID du nouveau compte Hedera au profil de l'utilisateur
            userService.linkHederaAccount(userPrincipal.getId(), newAccountInfo.getAccountId());

            // Retourner les informations du compte (y compris la clé privée) à l'utilisateur
            // L'utilisateur est responsable de sauvegarder cette clé privée en toute sécurité.
            // Le backend NE DOIT PAS stocker cette clé privée.
            return ResponseEntity.ok(ApiResponse.success("Compte Hedera créé et lié avec succès.", newAccountInfo));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Erreur lors de la création du compte Hedera: " + e.getMessage()));
        }
    }

    @PostMapping("/hedera/submit-signed-transaction")
    @Operation(summary = "Soumettre une transaction Hedera signée", description = "Reçoit une transaction Hedera signée par le client et la soumet au réseau.")
    public ResponseEntity<ApiResponse<String>> submitSignedHederaTransaction(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestBody String signedTransactionBytesBase64) { // Expecting Base64 encoded signed transaction bytes
        try {
            // No need to check user's Hedera account here, as the transaction is already signed by them
            String txId = hederaService.submitSignedTransaction(signedTransactionBytesBase64);
            return ResponseEntity.ok(ApiResponse.success("Transaction signée soumise avec succès.", txId));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Erreur lors de la soumission de la transaction signée: " + e.getMessage()));
        }
    }
}
