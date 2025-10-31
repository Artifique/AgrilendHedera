package com.agrilend.backend.service;

import com.agrilend.backend.dto.purchase.WarehouseReceiptDto;
import com.agrilend.backend.entity.WarehouseReceipt;
import com.agrilend.backend.repository.WarehouseReceiptRepository;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class BuyerServiceImpl implements BuyerService {

    @Autowired
    private WarehouseReceiptRepository warehouseReceiptRepository;

    @Autowired
    private ModelMapper modelMapper;

    @Override
    public List<WarehouseReceiptDto> getWarehouseReceipts() {
        List<WarehouseReceipt> receipts = warehouseReceiptRepository.findAll();
        return receipts.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    private WarehouseReceiptDto convertToDto(WarehouseReceipt receipt) {
        WarehouseReceiptDto dto = modelMapper.map(receipt, WarehouseReceiptDto.class);
        dto.setFarmerName(receipt.getFarmer().getUser().getFirstName() + " " + receipt.getFarmer().getUser().getLastName());
        dto.setProductName(receipt.getProduct().getName());
        return dto;
    }

}
