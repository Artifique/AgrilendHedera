package com.agrilend.backend.dto.tokenization;

import jakarta.validation.constraints.NotBlank;

public class HcsSubmitRequest {

    @NotBlank
    private String topicId; // e.g., 0.0.xxxxx

    @NotBlank
    private String message;

    public String getTopicId() { return topicId; }
    public void setTopicId(String topicId) { this.topicId = topicId; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}


