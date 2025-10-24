package com.agrilend.backend.controller;

import com.agrilend.backend.dto.common.ApiResponse;
import com.agrilend.backend.dto.common.PageResponse;
import com.agrilend.backend.dto.notification.NotificationDto;
import com.agrilend.backend.security.UserPrincipal;
import com.agrilend.backend.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
@Tag(name = "Notifications", description = "API de gestion des notifications")
@SecurityRequirement(name = "bearerAuth")
@CrossOrigin(origins = "*", maxAge = 3600)
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @GetMapping
    @Operation(summary = "Obtenir les notifications", description = "Récupère toutes les notifications de l'utilisateur connecté")
    public ResponseEntity<ApiResponse<List<NotificationDto>>> getNotifications(
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        try {
            List<NotificationDto> notifications = notificationService.getUserNotifications(userPrincipal.getId());
            return ResponseEntity.ok(ApiResponse.success("Notifications récupérées avec succès", notifications));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Erreur lors de la récupération des notifications: " + e.getMessage()));
        }
    }

    @GetMapping("/paginated")
    @Operation(summary = "Obtenir les notifications paginées", description = "Récupère les notifications de l'utilisateur avec pagination")
    public ResponseEntity<ApiResponse<PageResponse<NotificationDto>>> getNotificationsPaginated(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        try {
            Sort sort = sortDir.equalsIgnoreCase("desc") ? 
                Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
            Pageable pageable = PageRequest.of(page, size, sort);
            
            Page<NotificationDto> notifications = notificationService.getUserNotifications(userPrincipal.getId(), pageable);
            
            PageResponse<NotificationDto> pageResponse = new PageResponse<>(
                notifications.getContent(),
                notifications.getNumber(),
                notifications.getSize(),
                notifications.getTotalElements(),
                notifications.getTotalPages(),
                notifications.isFirst(),
                notifications.isLast(),
                notifications.isEmpty()
            );
            
            return ResponseEntity.ok(ApiResponse.success("Notifications récupérées avec succès", pageResponse));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Erreur lors de la récupération des notifications: " + e.getMessage()));
        }
    }

    @PostMapping("/{notificationId}/read")
    @Operation(summary = "Marquer comme lue", description = "Marque une notification comme lue")
    public ResponseEntity<ApiResponse<NotificationDto>> markAsRead(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long notificationId) {
        try {
            NotificationDto notification = notificationService.markAsRead(notificationId, userPrincipal.getId());
            return ResponseEntity.ok(ApiResponse.success("Notification marquée comme lue", notification));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Erreur lors du marquage: " + e.getMessage()));
        }
    }

    @PostMapping("/read-all")
    @Operation(summary = "Marquer toutes comme lues", description = "Marque toutes les notifications comme lues")
    public ResponseEntity<ApiResponse<String>> markAllAsRead(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        try {
            notificationService.markAllAsRead(userPrincipal.getId());
            return ResponseEntity.ok(ApiResponse.success("Toutes les notifications ont été marquées comme lues"));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Erreur lors du marquage: " + e.getMessage()));
        }
    }

    @GetMapping("/unread-count")
    @Operation(summary = "Compter les non lues", description = "Récupère le nombre de notifications non lues")
    public ResponseEntity<ApiResponse<Long>> getUnreadCount(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        try {
            long count = notificationService.getUnreadCount(userPrincipal.getId());
            return ResponseEntity.ok(ApiResponse.success("Nombre de notifications non lues récupéré", count));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Erreur lors du comptage: " + e.getMessage()));
        }
    }
}

