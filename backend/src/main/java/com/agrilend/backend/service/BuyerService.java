package com.agrilend.backend.service;

import com.agrilend.backend.dto.purchase.WarehouseReceiptDto;

import java.util.List;

public interface BuyerService {

    List<WarehouseReceiptDto> getWarehouseReceipts();

}
