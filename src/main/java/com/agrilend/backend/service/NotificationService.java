package com.agrilend.backend.service;

import com.agrilend.backend.dto.notification.NotificationDto;
import com.agrilend.backend.entity.*;
import com.agrilend.backend.entity.enums.OrderStatus;
import com.agrilend.backend.entity.enums.UserRole;
import com.agrilend.backend.repository.NotificationRepository;
import com.agrilend.backend.repository.UserRepository;
import org.modelmapper.ModelMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class NotificationService {

    private static final Logger logger = LoggerFactory.getLogger(NotificationService.class);

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired(required = false) // Make optional to avoid startup errors if not configured
    private JavaMailSender mailSender;

    @Autowired
    private ModelMapper modelMapper;

    public NotificationDto createNotification(Long userId, String title, String message, 
                                            String type, String relatedEntityType, Long relatedEntityId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé avec l\'ID: " + userId));

        Notification notification = new Notification();
        notification.setUser(user);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setType(type);
        notification.setRead(false);
        notification.setRelatedEntityType(relatedEntityType);
        notification.setRelatedEntityId(relatedEntityId);

        Notification savedNotification = notificationRepository.save(notification);

        // Send email
        if (mailSender == null) {
            logger.warn("Mail sender is not configured. Skipping email notification for user: {}", user.getEmail());
            return modelMapper.map(savedNotification, NotificationDto.class);
        }
        sendEmailNotification(user.getEmail(), title, message);

        return modelMapper.map(savedNotification, NotificationDto.class);
    }

    public void sendWelcomeNotification(User user) {
        String title = "Bienvenue sur AgriLend : Révolutionnez le Commerce Agricole !";
        String message = String.format(
            "Cher(e) %s %s,\n\n" +
            "Toute l'équipe d'Agrilend est ravie de vous accueillir sur notre plateforme innovante, dédiée à la modernisation du commerce agricole.\n\n" +
            "Agrilend connecte directement les agriculteurs et les acheteurs, en tirant parti de la technologie blockchain Hedera Hashgraph pour garantir des transactions transparentes, sécurisées et efficaces.\n\n" +
            "Voici ce que notre plateforme vous offre :\n\n" +
            "•   **Transparence et Traçabilité :** Chaque transaction est enregistrée sur Hedera, assurant une immuabilité et une visibilité complètes.\n" +
            "•   **Sécurité des Transactions :** Grâce à notre système basé sur la tokenisation des récoltes, les fonds sont sécurisés jusqu'à la confirmation de la livraison.\n" +
            "•   **Optimisation des Flux :** Nous simplifions la chaîne d'approvisionnement, réduisant les intermédiaires et garantissant la fraîcheur des produits.\n" +
            "•   **Accès Direct au Marché :** Que vous soyez agriculteur ou acheteur, Agrilend vous offre un accès direct à un marché dynamique et équitable.\n\n" +
            "Votre rôle en tant que %s est essentiel à notre écosystème. Nous vous invitons à explorer votre tableau de bord et à découvrir toutes les fonctionnalités mises à votre disposition.\n\n" +
            "Pour toute question ou assistance, n'hésitez pas à contacter notre équipe de support à l'adresse support@agrilend.com.\n\n" +
            "Nous sommes impatients de vous accompagner dans cette nouvelle ère du commerce agricole.\n\n" +
            "Cordialement,\n" +
            "L'équipe Agrilend",
            user.getFirstName(), user.getLastName(), user.getRole().name().toLowerCase()
        );
        
        createNotification(user.getId(), title, message, "WELCOME", "USER", user.getId());
    }

    public void notifyAdminsNewOffer(Offer offer) {
        List<User> admins = userRepository.findAllByRole(UserRole.ADMIN);
        String title = "Nouvelle offre en attente de validation";
        String message = String.format("L\'offre pour le produit '%s' soumise par %s attend votre validation.",
            offer.getProduct().getName(),
            offer.getFarmer().getUser().getFirstName());

        for (User admin : admins) {
            createNotification(admin.getId(), title, message, "NEW_OFFER", "OFFER", offer.getId());
        }
    }

    public void notifyFarmerOfferApproved(Offer offer) {
        User farmerUser = offer.getFarmer().getUser();
        String title = "Votre offre a été approuvée";
        String message = String.format("Bonne nouvelle ! Votre offre pour le produit '%s' a été approuvée.",
            offer.getProduct().getName());

        createNotification(farmerUser.getId(), title, message, "OFFER_APPROVED", "OFFER", offer.getId());
    }

    public void notifyFarmerOfferRejected(Offer offer, String reason) {
        User farmerUser = offer.getFarmer().getUser();
        String title = "Votre offre a été rejetée";
        String message = String.format("Votre offre pour le produit '%s' a été rejetée. Raison: %s",
            offer.getProduct().getName(), reason);

        createNotification(farmerUser.getId(), title, message, "OFFER_REJECTED", "OFFER", offer.getId());
    }

    public void notifyFarmerNewOrder(Order order) {
        User farmerUser = order.getOffer().getFarmer().getUser();
        String title = "Nouvelle commande reçue !";
        String message = String.format("Vous avez une nouvelle commande pour %.2f %s de '%s' de la part de %s.",
            order.getOrderedQuantity(),
            order.getOffer().getProduct().getUnit().name(),
            order.getOffer().getProduct().getName(),
            order.getBuyer().getUser().getFirstName());

        createNotification(farmerUser.getId(), title, message, "NEW_ORDER", "ORDER", order.getId());
    }

    public void notifyOrderEscrowed(Order order) {
        User buyerUser = order.getBuyer().getUser();
        String buyerTitle = "Confirmation de votre commande";
        String buyerMessage = String.format("Les fonds pour votre commande #%s ont été placés en séquestre. L\'agriculteur a été notifié.", order.getOrderNumber());
        createNotification(buyerUser.getId(), buyerTitle, buyerMessage, "ESCROW_CONFIRMED", "ORDER", order.getId());

        User farmerUser = order.getOffer().getFarmer().getUser();
        String farmerTitle = "Commande confirmée et sécurisée";
        String farmerMessage = String.format("La commande #%s est confirmée. Les fonds de l\'acheteur sont en séquestre.", order.getOrderNumber());
        createNotification(farmerUser.getId(), farmerTitle, farmerMessage, "ESCROW_CONFIRMED", "ORDER", order.getId());
    }

    public void notifyOrderStatusChanged(Order order, OrderStatus previousStatus, OrderStatus newStatus) {
        String title = "Mise à jour du statut de votre commande";
        String message = String.format("Le statut de votre commande #%s est passé de %s à %s.",
            order.getOrderNumber(), previousStatus.name(), newStatus.name());

        createNotification(order.getBuyer().getUser().getId(), title, message, "ORDER_STATUS_CHANGED", "ORDER", order.getId());
        createNotification(order.getOffer().getFarmer().getUser().getId(), title, message, "ORDER_STATUS_CHANGED", "ORDER", order.getId());
    }

    public void notifyEscrowReleased(Order order) {
        User farmerUser = order.getOffer().getFarmer().getUser();
        String farmerTitle = "Paiement reçu";
        String farmerMessage = String.format("Le paiement pour la commande #%s (%.2f €) a été transféré sur votre compte.",
            order.getOrderNumber(), order.getTotalAmount());
        createNotification(farmerUser.getId(), farmerTitle, farmerMessage, "PAYMENT_RELEASED", "ORDER", order.getId());

        User buyerUser = order.getBuyer().getUser();
        String buyerTitle = "Commande finalisée";
        String buyerMessage = String.format("La commande #%s est finalisée. Le paiement a été transféré à l\'agriculteur.",
            order.getOrderNumber());
        createNotification(buyerUser.getId(), buyerTitle, buyerMessage, "ESCROW_COMPLETED", "ORDER", order.getId());
    }

    public List<NotificationDto> getUserNotifications(Long userId) {
        List<Notification> notifications = notificationRepository.findByUserIdOrderByCreatedAtDesc(userId);
        return notifications.stream()
            .map(notification -> modelMapper.map(notification, NotificationDto.class))
            .collect(Collectors.toList());
    }

    public Page<NotificationDto> getUserNotifications(Long userId, Pageable pageable) {
        Page<Notification> notifications = notificationRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
        return notifications.map(notification -> modelMapper.map(notification, NotificationDto.class));
    }

    public NotificationDto markAsRead(Long notificationId, Long userId) {
        Notification notification = notificationRepository.findById(notificationId)
            .orElseThrow(() -> new RuntimeException("Notification non trouvée avec l\'ID: " + notificationId));

        if (!notification.getUser().getId().equals(userId)) {
            throw new RuntimeException("Vous n\'êtes pas autorisé à modifier cette notification");
        }

        notification.setRead(true);
        Notification updatedNotification = notificationRepository.save(notification);

        return modelMapper.map(updatedNotification, NotificationDto.class);
    }

    public void markAllAsRead(Long userId) {
        List<Notification> notifications = notificationRepository.findByUserIdAndIsReadFalse(userId);
        notifications.forEach(notification -> notification.setRead(true));
        notificationRepository.saveAll(notifications);
    }

    public long getUnreadCount(Long userId) {
        return notificationRepository.countByUserIdAndIsReadFalse(userId);
    }

    private void sendEmailNotification(String to, String subject, String text) {
        if (mailSender == null) {
            logger.warn("Mail sender is not configured. Skipping email notification for user: {}", to);
            return;
        }
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom("noreply@agrilend.com");
            message.setTo(to);
            message.setSubject(subject);
            message.setText(text);
            System.out.println("Attempting to send email...");
            mailSender.send(message);
            System.out.println("Email sending completed (no exception thrown).");
                    } catch (Exception e) {
                        logger.error("Erreur lors de l'envoi de l'email à {}: {}", to, e.getMessage(), e);
                        e.printStackTrace(System.err);
                    }    }
}