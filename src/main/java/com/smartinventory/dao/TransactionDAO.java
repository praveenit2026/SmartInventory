package com.smartinventory.dao;

import com.smartinventory.model.Transaction;
import com.smartinventory.util.ConnectionProvider;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class TransactionDAO {

    public List<Transaction> getAllTransactions() {
        List<Transaction> list = new ArrayList<>();
        String query = "SELECT t.*, p.name as product_name, p.sku as product_sku, u.fullname as user_fullname FROM transactions t " +
                       "JOIN products p ON t.product_id = p.id " +
                       "JOIN users u ON t.user_id = u.id " +
                       "ORDER BY t.transaction_date DESC";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Transaction t = new Transaction();
                t.setId(rs.getInt("id"));
                t.setProductId(rs.getInt("product_id"));
                t.setUserId(rs.getInt("user_id"));
                t.setType(rs.getString("type"));
                t.setQuantity(rs.getInt("quantity"));
                t.setTransactionDate(rs.getTimestamp("transaction_date"));
                t.setNotes(rs.getString("notes"));
                t.setProductName(rs.getString("product_name"));
                t.setSku(rs.getString("product_sku"));
                t.setUserFullname(rs.getString("user_fullname"));
                list.add(t);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addTransaction(Transaction t) {
        String insertQuery = "INSERT INTO transactions (product_id, user_id, type, quantity, notes) VALUES (?, ?, ?, ?, ?)";
        String updateProductQuery = "UPDATE products SET stock_quantity = stock_quantity + ? WHERE id = ?";
        
        Connection con = null;
        PreparedStatement insertPs = null;
        PreparedStatement updatePs = null;
        
        try {
            con = ConnectionProvider.getConnection();
            if (con == null) return false;
            
            con.setAutoCommit(false); // Begin Transaction
            
            // 1. Insert Transaction Log
            insertPs = con.prepareStatement(insertQuery);
            insertPs.setInt(1, t.getProductId());
            insertPs.setInt(2, t.getUserId());
            insertPs.setString(3, t.getType());
            insertPs.setInt(4, t.getQuantity());
            insertPs.setString(5, t.getNotes());
            
            int inserted = insertPs.executeUpdate();
            if (inserted == 0) {
                con.rollback();
                return false;
            }
            
            // 2. Adjust Product Stock Level
            int qtyChange = t.getQuantity();
            if ("STOCK_OUT".equalsIgnoreCase(t.getType())) {
                qtyChange = -qtyChange; // Subtract stock
            }
            
            updatePs = con.prepareStatement(updateProductQuery);
            updatePs.setInt(1, qtyChange);
            updatePs.setInt(2, t.getProductId());
            
            int updated = updatePs.executeUpdate();
            if (updated == 0) {
                con.rollback();
                return false;
            }
            
            con.commit(); // Commit Transaction
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            if (con != null) {
                try {
                    con.rollback(); // Rollback on Exception
                } catch (Exception rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            return false;
        } finally {
            try { if (insertPs != null) insertPs.close(); } catch (Exception ignored) {}
            try { if (updatePs != null) updatePs.close(); } catch (Exception ignored) {}
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }
}
