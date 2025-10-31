package com.agrilend.backend.dto.purchase;

public class PrepareDepositResponse {

    private String unsignedTransaction;

    public PrepareDepositResponse(String unsignedTransaction) {
        this.unsignedTransaction = unsignedTransaction;
    }

    public String getUnsignedTransaction() {
        return unsignedTransaction;
    }

    public void setUnsignedTransaction(String unsignedTransaction) {
        this.unsignedTransaction = unsignedTransaction;
    }
}
