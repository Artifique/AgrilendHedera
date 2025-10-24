package com.agrilend.backend.service;

import com.agrilend.backend.dto.order.CreateOrderRequest;
import com.agrilend.backend.dto.order.OrderDto;
import com.agrilend.backend.entity.*;
import com.agrilend.backend.entity.enums.OfferStatus;
import com.agrilend.backend.entity.enums.OrderStatus;
import com.agrilend.backend.repository.*;
import org.modelmapper.ModelMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class OrderService {

    private static final Logger logger = LoggerFactory.getLogger(OrderService.class);

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private OfferRepository offerRepository;

    @Autowired
    private BuyerRepository buyerRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ModelMapper modelMapper;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private EscrowService escrowService;

    @Autowired
    private HederaService hederaService;

    public OrderDto createOrder(Long buyerId, CreateOrderRequest request) {
        logger.info("Début de la création de commande pour l'acheteur ID: {}", buyerId);
        Buyer buyer = buyerRepository.findById(buyerId)
                .orElseThrow(() -> new RuntimeException("Acheteur non trouvé avec l'ID: " + buyerId));
        User buyerUser = buyer.getUser();
        logger.info("Acheteur trouvé: {}", buyerUser.getEmail());

        // --- Vérifier l'offre ---
        Offer offer = offerRepository.findById(request.getOfferId())
                .orElseThrow(() -> new RuntimeException("Offre non trouvée avec l'ID: " + request.getOfferId()));
        logger.info("Offre trouvée: {} (Statut: {}, Quantité disponible: {})", offer.getId(), offer.getStatus(), offer.getAvailableQuantity());

        if (offer.getStatus() != OfferStatus.ACTIVE) {
            throw new RuntimeException("Cette offre n'est pas active");
        }
        if (request.getOrderedQuantity().compareTo(offer.getAvailableQuantity()) > 0) {
            throw new RuntimeException("Quantité demandée supérieure à la quantité disponible");
        }

        // --- Calcul du montant total ---
        BigDecimal unitPrice = offer.getFinalPriceBuyer();
        BigDecimal totalAmount = unitPrice.multiply(request.getOrderedQuantity());

        // --- Créer l'objet Order ---
        Order order = new Order();
        order.setOffer(offer);
        order.setBuyer(buyer);
        order.setOrderedQuantity(request.getOrderedQuantity());
        order.setUnitPrice(unitPrice);
        order.setTotalAmount(totalAmount);
        order.setStatus(OrderStatus.PENDING);
        order.setDeliveryAddress(request.getDeliveryAddress());
        order.setNotes(request.getNotes());
        order = orderRepository.save(order); // sauvegarde initiale

        try {
            // --- 1. Créer un compte Hedera pour l’acheteur si nécessaire ---
            if (buyerUser.getHederaAccountId() == null || buyerUser.getHederaPrivateKey() == null) {
                HederaService.HederaAccountInfo accountInfo = hederaService.createAccount(buyerUser.getEmail());
                buyerUser.setHederaAccountId(accountInfo.getAccountId());
                buyerUser.setHederaPrivateKey(accountInfo.getPrivateKey());
                userRepository.save(buyerUser);
                logger.info("Compte Hedera créé pour l'acheteur: {}", accountInfo.getAccountId());
            }

            // --- 2. Alimenter le compte avec HBAR de test (Testnet) ---
            BigDecimal initialHbar = totalAmount.add(new BigDecimal("1.0")); // marge pour frais
            hederaService.transferHbarFromOperator(buyerUser.getHederaAccountId(), initialHbar);
            logger.info("Compte Hedera de l'acheteur alimenté avec {} HBAR", initialHbar);

            // --- 3. Initier le séquestre Hedera ---
            String txId = escrowService.initiateEscrow(order);
            order.setEscrowTransactionId(txId);
            order.setStatus(OrderStatus.IN_ESCROW);
            order.setEscrowStartDate(LocalDateTime.now());
            order.setEscrowEndDate(LocalDateTime.now().plusMonths(3));
            order = orderRepository.save(order);
            logger.info("Séquestre Hedera initié. Transaction ID: {}", txId);

        } catch (Exception e) {
            logger.error("Erreur lors de l'initiation du séquestre Hedera pour la commande {}: {}", order.getId(), e.getMessage(), e);
            throw new RuntimeException("Erreur lors de l'initiation du séquestre Hedera: " + e.getMessage());
        }

        // --- 4. Mettre à jour la quantité disponible de l'offre ---
        offer.setAvailableQuantity(offer.getAvailableQuantity().subtract(request.getOrderedQuantity()));
        if (offer.getAvailableQuantity().compareTo(BigDecimal.ZERO) == 0) {
            offer.setStatus(OfferStatus.SOLD_OUT);
        }
        offerRepository.save(offer);

        // --- 5. Retourner l'objet DTO ---
        return mapToDto(order);
    }

    public OrderDto confirmEscrow(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Commande non trouvée avec l'ID: " + orderId));

        order.setStatus(OrderStatus.IN_ESCROW);
        return mapToDto(orderRepository.save(order));
    }

    public OrderDto updateOrderStatus(Long orderId, OrderStatus status) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Commande non trouvée avec l'ID: " + orderId));
        order.setStatus(status);
        return mapToDto(orderRepository.save(order));
    }

    public OrderDto releaseEscrow(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Commande non trouvée avec l'ID: " + orderId));

        if (order.getStatus() != OrderStatus.IN_ESCROW) {
            throw new RuntimeException("La commande n'est pas en séquestre");
        }

        escrowService.releaseEscrow(order);
        order.setStatus(OrderStatus.RELEASED);
        return mapToDto(orderRepository.save(order));
    }

    public OrderDto getOrderById(Long orderId) {
        return mapToDto(orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Commande non trouvée avec l'ID: " + orderId)));
    }

    public List<OrderDto> getOrdersByBuyer(Long buyerId) {
        return orderRepository.findByBuyerId(buyerId).stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public List<OrderDto> getOrdersByFarmer(Long farmerId) {
        return orderRepository.findByOfferFarmerId(farmerId).stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public Page<OrderDto> getAllOrders(Pageable pageable) {
        return orderRepository.findAll(pageable).map(this::mapToDto);
    }

    public Page<OrderDto> getOrdersByStatus(OrderStatus status, Pageable pageable) {
        return orderRepository.findByStatus(status, pageable).map(this::mapToDto);
    }

    private OrderDto mapToDto(Order order) {
        OrderDto dto = modelMapper.map(order, OrderDto.class);

        Offer offer = order.getOffer();
        Product product = offer.getProduct();
        Farmer farmer = offer.getFarmer();
        User farmerUser = userRepository.findById(farmer.getId())
                .orElseThrow(() -> new RuntimeException("User for farmer not found"));
        User buyerUser = userRepository.findById(order.getBuyer().getId())
                .orElseThrow(() -> new RuntimeException("User for buyer not found"));

        dto.setOfferId(offer.getId());
        dto.setProductName(product.getName());
        dto.setProductUnit(product.getUnit().name());
        dto.setFarmerId(farmer.getId());
        dto.setFarmerName(farmerUser.getFirstName() + " " + farmerUser.getLastName());
        dto.setBuyerId(order.getBuyer().getId());
        dto.setBuyerName(buyerUser.getFirstName() + " " + buyerUser.getLastName());
        dto.setBuyerEmail(buyerUser.getEmail());

        return dto;
    }
}
