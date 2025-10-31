package com.agrilend.backend.dto.purchase;

public class PrepareRedeemResponse {

    private String unsignedTransaction;

    public PrepareRedeemResponse(String unsignedTransaction) {
        this.unsignedTransaction = unsignedTransaction;
    }

    public String getUnsignedTransaction() {
        return unsignedTransaction;
    }

    public void setUnsignedTransaction(String unsignedTransaction) {
        this.unsignedTransaction = unsignedTransaction;
    }
}
