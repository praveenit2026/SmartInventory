package com.smartinventory.model;

import java.sql.Timestamp;

public class Alert {
    private int id;
    private String type; // LOW_STOCK, NEAR_EXPIRY, EXPIRED
    private int productId;
    private String message;
    private boolean isRead;
    private Timestamp createdAt;

    // Helper fields
    private String productName;
    private String sku;

    public Alert() {}

    public Alert(int id, String type, int productId, String message, boolean isRead, Timestamp createdAt) {
        this.id = id;
        this.type = type;
        this.productId = productId;
        this.message = message;
        this.isRead = isRead;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public boolean isRead() {
        return isRead;
    }

    public void setRead(boolean read) {
        isRead = read;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }
}
