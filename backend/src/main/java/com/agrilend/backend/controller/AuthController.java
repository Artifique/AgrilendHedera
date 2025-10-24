package com.agrilend.backend.controller;

import com.agrilend.backend.dto.auth.JwtAuthenticationResponse;
import com.agrilend.backend.dto.auth.LoginRequest;
import com.agrilend.backend.dto.auth.SignupRequest;
import com.agrilend.backend.dto.common.ApiResponse;
import com.agrilend.backend.entity.User;
import com.agrilend.backend.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Authentication", description = "API d'authentification")
@CrossOrigin(origins = "*", maxAge = 3600)
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/login")
    @Operation(summary = "Connexion utilisateur", description = "Authentifie un utilisateur et retourne un token JWT")
    public ResponseEntity<ApiResponse<JwtAuthenticationResponse>> authenticateUser(@Valid @RequestBody LoginRequest loginRequest) {
        try {
            JwtAuthenticationResponse response = authService.authenticateUser(loginRequest);
            return ResponseEntity.ok(ApiResponse.success("Connexion réussie", response));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Erreur de connexion: " + e.getMessage()));
        }
    }

    @PostMapping("/register")
    @Operation(summary = "Inscription utilisateur", description = "Crée un nouveau compte utilisateur")
    public ResponseEntity<ApiResponse<String>> registerUser(@Valid @RequestBody SignupRequest signUpRequest) {
        try {
            User user = authService.registerUser(signUpRequest);
            return ResponseEntity.ok(ApiResponse.success(
                "Utilisateur enregistré avec succès. ID: " + user.getId()));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Erreur d'inscription: " + e.getMessage()));
        }
    }

    @PostMapping("/refresh")
    @Operation(summary = "Rafraîchir le token", description = "Génère un nouveau token d'accès à partir du token de rafraîchissement")
    public ResponseEntity<ApiResponse<JwtAuthenticationResponse>> refreshToken(@RequestParam String refreshToken) {
        try {
            JwtAuthenticationResponse response = authService.refreshToken(refreshToken);
            return ResponseEntity.ok(ApiResponse.success("Token rafraîchi avec succès", response));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Erreur de rafraîchissement: " + e.getMessage()));
        }
    }

    @PostMapping("/logout")
    @Operation(summary = "Déconnexion", description = "Déconnecte l'utilisateur")
    public ResponseEntity<ApiResponse<String>> logout() {
        // Dans une implémentation complète, on pourrait blacklister le token
        return ResponseEntity.ok(ApiResponse.success("Déconnexion réussie"));
    }
}

