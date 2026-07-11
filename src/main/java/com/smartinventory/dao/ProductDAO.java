package com.smartinventory.dao;

import com.smartinventory.model.Product;
import com.smartinventory.util.ConnectionProvider;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ProductDAO {

    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        String query = "SELECT p.*, s.name as supplier_name FROM products p " +
                       "LEFT JOIN suppliers s ON p.supplier_id = s.id ORDER BY p.name ASC";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setSku(rs.getString("sku"));
                p.setName(rs.getString("name"));
                p.setDescription(rs.getString("description"));
                p.setCategory(rs.getString("category"));
                p.setPrice(rs.getDouble("price"));
                p.setStockQuantity(rs.getInt("stock_quantity"));
                p.setMinStockLevel(rs.getInt("min_stock_level"));
                p.setExpiryDate(rs.getDate("expiry_date"));
                p.setSupplierId(rs.getInt("supplier_id"));
                p.setSupplierName(rs.getString("supplier_name"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Product getProductById(int id) {
        Product p = null;
        String query = "SELECT p.*, s.name as supplier_name FROM products p " +
                       "LEFT JOIN suppliers s ON p.supplier_id = s.id WHERE p.id = ?";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
            
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    p = new Product();
                    p.setId(rs.getInt("id"));
                    p.setSku(rs.getString("sku"));
                    p.setName(rs.getString("name"));
                    p.setDescription(rs.getString("description"));
                    p.setCategory(rs.getString("category"));
                    p.setPrice(rs.getDouble("price"));
                    p.setStockQuantity(rs.getInt("stock_quantity"));
                    p.setMinStockLevel(rs.getInt("min_stock_level"));
                    p.setExpiryDate(rs.getDate("expiry_date"));
                    p.setSupplierId(rs.getInt("supplier_id"));
                    p.setSupplierName(rs.getString("supplier_name"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return p;
    }

    public boolean addProduct(Product p) {
        String query = "INSERT INTO products (sku, name, description, category, price, stock_quantity, min_stock_level, expiry_date, supplier_id) " +
                       "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
            
            ps.setString(1, p.getSku());
            ps.setString(2, p.getName());
            ps.setString(3, p.getDescription());
            ps.setString(4, p.getCategory());
            ps.setDouble(5, p.getPrice());
            ps.setInt(6, p.getStockQuantity());
            ps.setInt(7, p.getMinStockLevel());
            ps.setDate(8, p.getExpiryDate());
            if (p.getSupplierId() > 0) {
                ps.setInt(9, p.getSupplierId());
            } else {
                ps.setNull(9, java.sql.Types.INTEGER);
            }
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateProduct(Product p) {
        String query = "UPDATE products SET sku=?, name=?, description=?, category=?, price=?, stock_quantity=?, min_stock_level=?, expiry_date=?, supplier_id=? " +
                       "WHERE id=?";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
            
            ps.setString(1, p.getSku());
            ps.setString(2, p.getName());
            ps.setString(3, p.getDescription());
            ps.setString(4, p.getCategory());
            ps.setDouble(5, p.getPrice());
            ps.setInt(6, p.getStockQuantity());
            ps.setInt(7, p.getMinStockLevel());
            ps.setDate(8, p.getExpiryDate());
            if (p.getSupplierId() > 0) {
                ps.setInt(9, p.getSupplierId());
            } else {
                ps.setNull(9, java.sql.Types.INTEGER);
            }
            ps.setInt(10, p.getId());
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteProduct(int id) {
        String query = "DELETE FROM products WHERE id=?";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateStock(int productId, int quantityChange) {
        String query = "UPDATE products SET stock_quantity = stock_quantity + ? WHERE id = ?";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
            ps.setInt(1, quantityChange);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // --- Metric Queries for Dashboard Analytics ---

    public Map<String, Integer> getDashboardMetrics() {
        Map<String, Integer> metrics = new HashMap<>();
        String query = "SELECT " +
                       "(SELECT COUNT(*) FROM products) as total_products, " +
                       "(SELECT COUNT(*) FROM products WHERE stock_quantity <= min_stock_level) as low_stock, " +
                       "(SELECT COUNT(*) FROM products WHERE expiry_date IS NOT NULL AND expiry_date < CURDATE()) as expired, " +
                       "(SELECT COUNT(*) FROM products WHERE expiry_date IS NOT NULL AND expiry_date >= CURDATE() AND expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)) as near_expiry";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                metrics.put("total_products", rs.getInt("total_products"));
                metrics.put("low_stock", rs.getInt("low_stock"));
                metrics.put("expired", rs.getInt("expired"));
                metrics.put("near_expiry", rs.getInt("near_expiry"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return metrics;
    }

    public int getTotalProductCount() {
        int count = 0;
        String query = "SELECT COUNT(*) FROM products";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    public int getLowStockCount() {
        int count = 0;
        String query = "SELECT COUNT(*) FROM products WHERE stock_quantity <= min_stock_level";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    public int getExpiredCount() {
        int count = 0;
        String query = "SELECT COUNT(*) FROM products WHERE expiry_date IS NOT NULL AND expiry_date < CURDATE()";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    public int getNearExpiryCount() {
        int count = 0;
        // Expires in next 30 days but not yet expired
        String query = "SELECT COUNT(*) FROM products WHERE expiry_date IS NOT NULL AND expiry_date >= CURDATE() AND expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    public Map<String, Integer> getCategoryDistribution() {
        Map<String, Integer> map = new HashMap<>();
        String query = "SELECT category, COUNT(*) as count FROM products GROUP BY category";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String cat = rs.getString("category");
                if (cat == null || cat.trim().isEmpty()) {
                    cat = "Uncategorized";
                }
                map.put(cat, rs.getInt("count"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }
}
