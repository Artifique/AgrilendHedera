package com.agrilend.backend.dto.purchase;

public class PrepareAssociateResponse {

    private String unsignedTransaction;

    public PrepareAssociateResponse(String unsignedTransaction) {
        this.unsignedTransaction = unsignedTransaction;
    }

    public String getUnsignedTransaction() {
        return unsignedTransaction;
    }

    public void setUnsignedTransaction(String unsignedTransaction) {
        this.unsignedTransaction = unsignedTransaction;
    }
}
