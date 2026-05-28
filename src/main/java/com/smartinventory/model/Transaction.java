package com.smartinventory.model;

import java.sql.Timestamp;

public class Transaction {
    private int id;
    private int productId;
    private int userId;
    private String type; // STOCK_IN, STOCK_OUT
    private int quantity;
    private Timestamp transactionDate;
    private String notes;

    // Helper fields for UI Display
    private String productName;
    private String sku;
    private String userFullname;

    public Transaction() {}

    public Transaction(int id, int productId, int userId, String type, int quantity, Timestamp transactionDate, String notes) {
        this.id = id;
        this.productId = productId;
        this.userId = userId;
        this.type = type;
        this.quantity = quantity;
        this.transactionDate = transactionDate;
        this.notes = notes;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public Timestamp getTransactionDate() {
        return transactionDate;
    }

    public void setTransactionDate(Timestamp transactionDate) {
        this.transactionDate = transactionDate;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
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

    public String getUserFullname() {
        return userFullname;
    }

    public void setUserFullname(String userFullname) {
        this.userFullname = userFullname;
    }
}
