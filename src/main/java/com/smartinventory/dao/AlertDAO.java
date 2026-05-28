package com.smartinventory.dao;

import com.smartinventory.model.Alert;
import com.smartinventory.util.ConnectionProvider;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class AlertDAO {

    public List<Alert> getAllAlerts() {
        List<Alert> list = new ArrayList<>();
        String query = "SELECT a.*, p.name as product_name, p.sku as product_sku FROM alerts a " +
                       "JOIN products p ON a.product_id = p.id " +
                       "ORDER BY a.created_at DESC";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Alert a = new Alert();
                a.setId(rs.getInt("id"));
                a.setType(rs.getString("type"));
                a.setProductId(rs.getInt("product_id"));
                a.setMessage(rs.getString("message"));
                a.setRead(rs.getBoolean("is_read"));
                a.setCreatedAt(rs.getTimestamp("created_at"));
                a.setProductName(rs.getString("product_name"));
                a.setSku(rs.getString("product_sku"));
                list.add(a);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Alert> getUnreadAlerts() {
        List<Alert> list = new ArrayList<>();
        String query = "SELECT a.*, p.name as product_name, p.sku as product_sku FROM alerts a " +
                       "JOIN products p ON a.product_id = p.id " +
                       "WHERE a.is_read = FALSE ORDER BY a.created_at DESC";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Alert a = new Alert();
                a.setId(rs.getInt("id"));
                a.setType(rs.getString("type"));
                a.setProductId(rs.getInt("product_id"));
                a.setMessage(rs.getString("message"));
                a.setRead(rs.getBoolean("is_read"));
                a.setCreatedAt(rs.getTimestamp("created_at"));
                a.setProductName(rs.getString("product_name"));
                a.setSku(rs.getString("product_sku"));
                list.add(a);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addAlertIfNotExists(String type, int productId, String message) {
        // Prevent duplicate unread alerts of the same type for the same product to avoid spamming the dashboard
        String checkQuery = "SELECT COUNT(*) FROM alerts WHERE type = ? AND product_id = ? AND is_read = FALSE";
        String insertQuery = "INSERT INTO alerts (type, product_id, message) VALUES (?, ?, ?)";
        
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement checkPs = con.prepareStatement(checkQuery)) {
            
            checkPs.setString(1, type);
            checkPs.setInt(2, productId);
            
            try (ResultSet rs = checkPs.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return false; // Alert already exists
                }
            }
            
            try (PreparedStatement insertPs = con.prepareStatement(insertQuery)) {
                insertPs.setString(1, type);
                insertPs.setInt(2, productId);
                insertPs.setString(3, message);
                return insertPs.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean markAsRead(int alertId) {
        String query = "UPDATE alerts SET is_read = TRUE WHERE id = ?";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
            ps.setInt(1, alertId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean markAllAsRead() {
        String query = "UPDATE alerts SET is_read = TRUE WHERE is_read = FALSE";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
