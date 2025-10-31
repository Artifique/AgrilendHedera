package com.agrilend.backend.service;

import com.agrilend.backend.dto.tokenization.HarvestTokenDto;
import com.agrilend.backend.entity.HarvestToken;
import com.agrilend.backend.repository.HarvestTokenRepository;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class HarvestTokenService {

    @Autowired
    private HarvestTokenRepository harvestTokenRepository;

    @Autowired
    private ModelMapper modelMapper;

    public List<HarvestToken> getAllHarvestTokens() {
        return harvestTokenRepository.findAll();
    }

    public HarvestToken getHarvestTokenByHederaId(String hederaTokenId) {
        return harvestTokenRepository.findByHederaTokenId(hederaTokenId)
            .orElse(null); // Ou jeter une exception si non trouvé
    }

    public HarvestToken saveHarvestToken(HarvestToken harvestToken) {
        return harvestTokenRepository.save(harvestToken);
    }

    public HarvestTokenDto convertToDto(HarvestToken harvestToken) {
        HarvestTokenDto dto = modelMapper.map(harvestToken, HarvestTokenDto.class);
        if (harvestToken.getWarehouseReceipt() != null) {
            dto.setWarehouseReceiptId(harvestToken.getWarehouseReceipt().getId());
            dto.setWarehouseReceiptBatchNumber(harvestToken.getWarehouseReceipt().getBatchNumber());
            dto.setWarehouseReceiptNetWeight(harvestToken.getWarehouseReceipt().getNetWeight());
            dto.setWarehouseReceiptWeightUnit(harvestToken.getWarehouseReceipt().getWeightUnit());
            dto.setWarehouseReceiptQualityGrade(harvestToken.getWarehouseReceipt().getQualityGrade());
            if (harvestToken.getWarehouseReceipt().getFarmer() != null && harvestToken.getWarehouseReceipt().getFarmer().getUser() != null) {
                dto.setWarehouseReceiptFarmerFirstName(harvestToken.getWarehouseReceipt().getFarmer().getUser().getFirstName());
                dto.setWarehouseReceiptFarmerLastName(harvestToken.getWarehouseReceipt().getFarmer().getUser().getLastName());
            }
        }
        return dto;
    }

    public List<HarvestTokenDto> convertToDtoList(List<HarvestToken> harvestTokens) {
        return harvestTokens.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    // Ajoutez d'autres méthodes si nécessaire (ex: save, update)
}
