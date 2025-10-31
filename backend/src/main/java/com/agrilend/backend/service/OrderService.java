package com.agrilend.backend.service;

import com.agrilend.backend.dto.order.CreateOrderRequest;
import com.agrilend.backend.dto.order.OrderDto;
import com.agrilend.backend.entity.*;
import com.agrilend.backend.entity.enums.DepositStatus;
import com.agrilend.backend.entity.enums.OfferStatus;
import com.agrilend.backend.entity.enums.OrderStatus;
import com.agrilend.backend.repository.*;
import com.hedera.hashgraph.sdk.*;
import org.modelmapper.ModelMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Base64;
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

    @Autowired // Re-adding HederaService dependency
    private HederaService hederaService;

    @Autowired
    private HbarDepositService hbarDepositService;

    @Value("${hedera.treasury.account-id:}")
    private String treasuryAccountId;

    public OrderDto createOrder(Long buyerId, Long hbarDepositId, CreateOrderRequest request) {
        logger.info("Début de la création de commande pour l'acheteur ID: {} avec dépôt HBAR ID: {}", buyerId, hbarDepositId);
        Buyer buyer = buyerRepository.findById(buyerId)
                .orElseThrow(() -> new RuntimeException("Acheteur non trouvé avec l'ID: " + buyerId));

        HbarDeposit hbarDeposit = hbarDepositService.getDepositById(hbarDepositId);
        if (!hbarDeposit.getBuyer().getId().equals(buyerId)) {
            throw new RuntimeException("Le dépôt HBAR ne correspond pas à l'acheteur.");
        }
        if (hbarDeposit.getStatus() != DepositStatus.VERIFIED) {
            throw new RuntimeException("Le dépôt HBAR n'a pas été vérifié ou a échoué.");
        }

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

        // --- Calcul du montant total (doit correspondre à ce qui a été déposé ou être couvert par)
        BigDecimal unitPrice = offer.getFinalPriceBuyer();
        BigDecimal totalAmount = unitPrice.multiply(request.getOrderedQuantity());

        // Vérifier que le dépôt HBAR couvre le montant total de la commande
        // Pour simplifier, nous supposons que le dépôt fait pour une commande donnée est l'équivalent du montant de la commande
        // Dans un système réel, il faudrait gérer les dépôts multiples et les crédits. 
        if (hbarDeposit.getHbarAmount().compareTo(totalAmount) < 0) {
            throw new RuntimeException("Le montant déposé en HBAR est insuffisant pour cette commande.");
        }

        // --- Créer l'objet Order ---
        Order order = new Order();
        order.setOffer(offer);
        order.setBuyer(buyer);
        order.setOrderedQuantity(request.getOrderedQuantity());
        order.setUnitPrice(unitPrice);
        order.setTotalAmount(totalAmount);
        order.setStatus(OrderStatus.PENDING); // La commande est en attente après l'HBAR deposit
        order.setDeliveryAddress(request.getDeliveryAddress());
        order.setNotes(request.getNotes());
        order.setHbarDeposit(hbarDeposit); // Lien vers le dépôt HBAR
        
        Order savedOrder = orderRepository.save(order);
        logger.info("Commande {} créée et liée au dépôt HBAR {}. ", savedOrder.getId(), hbarDeposit.getId());

        // --- Mettre à jour la quantité disponible de l'offre ---
        offer.setAvailableQuantity(offer.getAvailableQuantity().subtract(request.getOrderedQuantity()));
        if (offer.getAvailableQuantity().compareTo(BigDecimal.ZERO) == 0) {
            offer.setStatus(OfferStatus.SOLD_OUT);
        }
        offerRepository.save(offer);

        // --- Envoyer des notifications ---
        // notificationService.notifyFarmerNewOrder(savedOrder);
        // notificationService.notifyBuyerOrderConfirmation(savedOrder);

        // --- Retourner l'objet DTO ---
        return mapToDto(savedOrder);
    }

    /**
     * Prépare une transaction non signée pour le transfert d'AgriTokens de l'acheteur vers la trésorerie.
     * Cette transaction doit être signée par l'acheteur côté client pour le rachat de produits.
     * @param buyerId L'ID de l'acheteur initiant le rachat.
     * @param tokenId L'ID de l'AgriToken à transférer.
     * @param amount Le montant d'AgriTokens à transférer (en unités complètes).
     * @return La transaction sérialisée en Base64.
     */
    public String redeemAgriTokens(Long buyerId, String tokenId, BigDecimal amount) {
        try {
            User buyerUser = userRepository.findById(buyerId)
                    .orElseThrow(() -> new RuntimeException("Acheteur non trouvé avec l'ID: " + buyerId));
            
            if (treasuryAccountId.isEmpty()) {
                throw new IllegalStateException("L'ID du compte trésorier (hedera.treasury.account-id) n'est pas configuré.");
            }
            if (buyerUser.getHederaAccountId() == null) { // Only check for Account ID, private key is client-side
                 throw new RuntimeException("Le compte Hedera de l'acheteur n'est pas configuré.");
            }

            // Convertir le montant en plus petite unité (assumant 2 décimales pour AgriToken)
            long amountSmallestUnit = amount.multiply(new BigDecimal("100")).longValue();

            // Créer la transaction de transfert
            TransferTransaction transaction = new TransferTransaction()
                    .addTokenTransfer(TokenId.fromString(tokenId), AccountId.fromString(buyerUser.getHederaAccountId()), -amountSmallestUnit)
                    .addTokenTransfer(TokenId.fromString(tokenId), AccountId.fromString(treasuryAccountId), amountSmallestUnit)
                    .freezeWith(hederaService.getClient());
            
            // La transaction n'est PAS signée ici. Elle sera signée par l'acheteur.
            return Base64.getEncoder().encodeToString(transaction.toBytes());

        } catch (Exception e) {
            logger.error("Erreur lors de la préparation de la transaction de rachat pour l'acheteur {}: {}", buyerId, e.getMessage(), e);
            throw new RuntimeException("Impossible de préparer la transaction de rachat: " + e.getMessage());
        }
    }

    public OrderDto updateOrderStatus(Long orderId, OrderStatus status) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Commande non trouvée avec l'ID: " + orderId));
        
        if (status == OrderStatus.IN_ESCROW || status == OrderStatus.RELEASED) {
            throw new IllegalArgumentException("Les statuts de séquestre ne sont plus applicables.");
        }

        order.setStatus(status);
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

    /**
     * Prépare une transaction non signée pour le dépôt de HBAR dans le HarvestVault.
     * Cette transaction doit être signée par l'acheteur côté client.
     * @param amount Le montant de HBAR à déposer.
     * @param buyerHederaAccountId L'ID du compte Hedera de l'acheteur.
     * @param vaultContractId L'ID du contrat HarvestVault.
     * @return La transaction sérialisée en Base64.
     */
    public String prepareDepositTransaction(BigDecimal amount, String buyerHederaAccountId, String vaultContractId) {
        try {
            // Convertir le montant en tinybars
            long amountInTinybars = amount.multiply(new BigDecimal("100000000")).longValue();

            // Créer la transaction d'exécution de contrat
            ContractExecuteTransaction transaction = new ContractExecuteTransaction()
                    .setContractId(ContractId.fromString(vaultContractId))
                    .setGas(100_000) // Ajuster le gaz si nécessaire
                    .setFunction("depositHbar") // Nom de la fonction dans HarvestVault
                    .setPayableAmount(Hbar.fromTinybars(amountInTinybars))
                    .freezeWith(hederaService.getClient()); // Geler la transaction avec le client opérateur

            // La transaction n'est PAS signée ici. Elle sera signée par l'acheteur.
            // Sérialiser la transaction en Base64 pour l'envoyer au frontend
            return Base64.getEncoder().encodeToString(transaction.toBytes());

        } catch (Exception e) {
            logger.error("Erreur lors de la préparation de la transaction de dépôt pour l'acheteur {}: {}", buyerHederaAccountId, e.getMessage(), e);
            throw new RuntimeException("Impossible de préparer la transaction de dépôt: " + e.getMessage());
        }
    }
    }
