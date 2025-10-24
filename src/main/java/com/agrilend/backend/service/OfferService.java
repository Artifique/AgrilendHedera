package com.agrilend.backend.service;

import com.agrilend.backend.dto.offer.OfferDto;
import com.agrilend.backend.entity.Farmer;
import com.agrilend.backend.entity.Offer;
import com.agrilend.backend.entity.Product;
import com.agrilend.backend.entity.User;
import com.agrilend.backend.entity.enums.OfferStatus;
import com.agrilend.backend.repository.FarmerRepository;
import com.agrilend.backend.repository.OfferRepository;
import com.agrilend.backend.repository.ProductRepository;
import com.agrilend.backend.repository.UserRepository;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class OfferService {

    private static final BigDecimal PLATFORM_MARGIN = new BigDecimal("0.05"); // 5% margin

    @Autowired
    private OfferRepository offerRepository;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private FarmerRepository farmerRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ModelMapper modelMapper;

    @Autowired
    private NotificationService notificationService;

    public OfferDto createOffer(Long farmerId, OfferDto offerDto) {
        Farmer farmer = farmerRepository.findById(farmerId)
                .orElseThrow(() -> new RuntimeException("Agriculteur non trouvé avec l'ID: " + farmerId));

        Product product = productRepository.findById(offerDto.getProductId())
                .orElseThrow(() -> new RuntimeException("Produit non trouvé avec l'ID: " + offerDto.getProductId()));

        Offer offer = new Offer();
        offer.setFarmer(farmer);
        offer.setProduct(product);
        offer.setAvailableQuantity(offerDto.getAvailableQuantity());
        offer.setAvailabilityDate(offerDto.getAvailabilityDate());
        offer.setSuggestedUnitPrice(offerDto.getSuggestedUnitPrice());
        offer.setStatus(OfferStatus.PENDING_VALIDATION);
        offer.setNotes(offerDto.getNotes());

        Offer savedOffer = offerRepository.save(offer);

        // notificationService.notifyAdminsNewOffer(savedOffer);

        return mapToDto(savedOffer);
    }

    public OfferDto updateOffer(Long offerId, Long farmerId, OfferDto offerDto) {
        Offer offer = offerRepository.findById(offerId)
                .orElseThrow(() -> new RuntimeException("Offre non trouvée avec l'ID: " + offerId));

        if (!offer.getFarmer().getId().equals(farmerId)) {
            throw new RuntimeException("Vous n'êtes pas autorisé à modifier cette offre");
        }

        if (offer.getStatus() != OfferStatus.PENDING_VALIDATION && offer.getStatus() != OfferStatus.DRAFT) {
            throw new RuntimeException("Seules les offres en brouillon ou en attente peuvent être modifiées");
        }

        offer.setAvailableQuantity(offerDto.getAvailableQuantity());
        offer.setAvailabilityDate(offerDto.getAvailabilityDate());
        offer.setSuggestedUnitPrice(offerDto.getSuggestedUnitPrice());
        offer.setNotes(offerDto.getNotes());

        return mapToDto(offerRepository.save(offer));
    }

    public void deleteOffer(Long offerId, Long farmerId) {
        Offer offer = offerRepository.findById(offerId)
                .orElseThrow(() -> new RuntimeException("Offre non trouvée avec l'ID: " + offerId));

        if (!offer.getFarmer().getId().equals(farmerId)) {
            throw new RuntimeException("Vous n'êtes pas autorisé à supprimer cette offre");
        }

        if (offer.getStatus() != OfferStatus.PENDING_VALIDATION && offer.getStatus() != OfferStatus.DRAFT) {
            throw new RuntimeException("Seules les offres en brouillon ou en attente peuvent être supprimées");
        }

        offerRepository.delete(offer);
    }

    public OfferDto approveOffer(Long offerId) {
        Offer offer = offerRepository.findById(offerId)
                .orElseThrow(() -> new RuntimeException("Offre non trouvée avec l'ID: " + offerId));

        BigDecimal suggestedPrice = offer.getSuggestedUnitPrice();
        BigDecimal finalPriceForBuyer = suggestedPrice.multiply(BigDecimal.ONE.add(PLATFORM_MARGIN)).setScale(2, RoundingMode.HALF_UP);

        offer.setFinalPriceBuyer(finalPriceForBuyer);
        offer.setFinalPriceFarmer(suggestedPrice); // The farmer gets their suggested price
        offer.setStatus(OfferStatus.ACTIVE);
        offer.setAdminValidated(true);
        offer.setValidatedAt(LocalDateTime.now());

        Offer approvedOffer = offerRepository.save(offer);

        // notificationService.notifyFarmerOfferApproved(approvedOffer);

        return mapToDto(approvedOffer);
    }

    public OfferDto rejectOffer(Long offerId, String reason) {
        Offer offer = offerRepository.findById(offerId)
                .orElseThrow(() -> new RuntimeException("Offre non trouvée avec l'ID: " + offerId));

        offer.setStatus(OfferStatus.REJECTED);
        offer.setRejectionReason(reason);

        Offer rejectedOffer = offerRepository.save(offer);

        // notificationService.notifyFarmerOfferRejected(rejectedOffer, reason);

        return mapToDto(rejectedOffer);
    }

    public OfferDto getOfferById(Long offerId) {
        return mapToDto(offerRepository.findById(offerId)
                .orElseThrow(() -> new RuntimeException("Offre non trouvée avec l'ID: " + offerId)));
    }

    public List<OfferDto> getOffersByFarmer(Long farmerId) {
        List<Offer> offers = offerRepository.findByFarmerId(farmerId);
        return offers.stream().map(this::mapToDto).collect(Collectors.toList());
    }

    public Page<OfferDto> getApprovedOffers(Pageable pageable) {
        return offerRepository.findByStatus(OfferStatus.ACTIVE, pageable)
                .map(this::mapToDto);
    }

    public Page<OfferDto> getPendingOffers(Pageable pageable) {
        return offerRepository.findByStatus(OfferStatus.PENDING_VALIDATION, pageable)
                .map(this::mapToDto);
    }

    public Page<OfferDto> getAllOffers(Pageable pageable) {
        return offerRepository.findAll(pageable).map(this::mapToDto);
    }

    private OfferDto mapToDto(Offer offer) {
        OfferDto dto = modelMapper.map(offer, OfferDto.class);

        Product product = offer.getProduct();
        dto.setProductId(product.getId());
        dto.setProductName(product.getName());
        dto.setProductDescription(product.getDescription());
        dto.setProductCategory(product.getCategory());
        dto.setProductUnit(product.getUnit().name());
        dto.setProductImageUrl(product.getImageUrl());
        if (offer.getProductionMethod() != null) {
            dto.setProductionMethod(offer.getProductionMethod().name());
        }

        Farmer farmer = offer.getFarmer();
        User farmerUser = userRepository.findById(farmer.getId())
                .orElseThrow(() -> new IllegalStateException("User not found for Farmer ID: " + farmer.getId()));
        dto.setFarmerId(farmer.getId());
        dto.setFarmerName(farmerUser.getFirstName() + " " + farmerUser.getLastName());
        dto.setFarmerEmail(farmerUser.getEmail());

        dto.setFinalUnitPrice(offer.getFinalPriceBuyer());

        return dto;
    }
}