package com.agrilend.backend.controller;

import com.agrilend.backend.dto.common.ApiResponse;
import com.agrilend.backend.dto.user.UserProfileDto;
import com.agrilend.backend.security.UserPrincipal;
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

@RestController
@RequestMapping("/api/user")
@Tag(name = "User Management", description = "API de gestion des utilisateurs")
@SecurityRequirement(name = "bearerAuth")
@CrossOrigin(origins = "*", maxAge = 3600)
public class UserController {

    @Autowired
    private UserService userService;

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
}

