package com.agrilend.backend.dto.tokenization;

import jakarta.validation.constraints.NotBlank;

public class ValidateWarehouseReceiptRequestDto {

    @NotBlank(message = "Le rapport d'inspection est obligatoire")
    private String inspectionReport;

    // Getters and Setters

    public String getInspectionReport() {
        return inspectionReport;
    }

    public void setInspectionReport(String inspectionReport) {
        this.inspectionReport = inspectionReport;
    }
}
