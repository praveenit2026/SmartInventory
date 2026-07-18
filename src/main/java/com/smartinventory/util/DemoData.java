package com.smartinventory.util;

import com.smartinventory.model.Product;
import com.smartinventory.model.Transaction;
import com.smartinventory.model.Alert;
import com.smartinventory.model.Supplier;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.*;

public class DemoData {
    private static final List<Product> products = new ArrayList<>();
    private static final List<Transaction> transactions = new ArrayList<>();
    private static final List<Alert> alerts = new ArrayList<>();
    private static final List<Supplier> suppliers = new ArrayList<>();

    private static int nextProductId = 100;
    private static int nextTransactionId = 100;
    private static int nextAlertId = 100;

    static {
        // 1. Initialize Suppliers
        suppliers.add(new Supplier(1, "FreshFarms Co", "Rajesh Kumar", "+91 98765 43210", "sales@freshfarms.in", "Tech Park, Bangalore"));
        suppliers.add(new Supplier(2, "Apex Dairy Ltd", "Sunita Sharma", "+91 91234 56789", "contact@apexdairy.com", "Sector 62, Noida"));
        suppliers.add(new Supplier(3, "Global Goods", "Anil Mehta", "+91 99887 76655", "supply@globalgoods.com", "Industrial Area, Hyderabad"));

        // 2. Initialize Products
        Calendar cal = Calendar.getInstance();
        
        cal.add(Calendar.DATE, 10);
        products.add(createDemoProduct(1, "SKU001", "Organic Apples (1kg)", "Crisp organic red apples.", "Fresh Produce", 150.00, 20, 5, new Date(cal.getTimeInMillis()), 1, "FreshFarms Co"));
        
        cal.setTime(new java.util.Date());
        cal.add(Calendar.DATE, 6);
        products.add(createDemoProduct(2, "SKU002", "Whole Milk (1L)", "Full-fat pasteurized cow milk.", "Dairy & Eggs", 60.00, 3, 5, new Date(cal.getTimeInMillis()), 2, "Apex Dairy Ltd"));
        
        cal.setTime(new java.util.Date());
        cal.add(Calendar.DATE, 15);
        products.add(createDemoProduct(3, "SKU003", "Brown Eggs (12pk)", "Free-range large brown eggs.", "Dairy & Eggs", 120.00, 35, 10, new Date(cal.getTimeInMillis()), 2, "Apex Dairy Ltd"));
        
        cal.setTime(new java.util.Date());
        cal.add(Calendar.DATE, 4);
        products.add(createDemoProduct(4, "SKU004", "Chicken Breast (1kg)", "Fresh boneless chicken breast.", "Meat & Seafood", 350.00, 15, 8, new Date(cal.getTimeInMillis()), 1, "FreshFarms Co"));
        
        cal.setTime(new java.util.Date());
        cal.add(Calendar.DATE, 2);
        products.add(createDemoProduct(5, "SKU005", "Fresh Salmon (500g)", "Wild caught Atlantic salmon.", "Meat & Seafood", 500.00, 1, 5, new Date(cal.getTimeInMillis()), 1, "FreshFarms Co"));
        
        cal.setTime(new java.util.Date());
        cal.add(Calendar.DATE, -2);
        products.add(createDemoProduct(6, "SKU007", "Butter Croissants (4pk)", "Flaky buttery bakery croissants.", "Bakery & Bread", 110.00, 2, 5, new Date(cal.getTimeInMillis()), 2, "Apex Dairy Ltd"));
        
        products.add(createDemoProduct(7, "SKU008", "Coca-Cola (1.25L)", "Classic carbonated soft drink.", "Beverages", 45.00, 50, 15, null, 3, "Global Goods"));
        products.add(createDemoProduct(8, "SKU009", "Sparkling Water (500ml)", "Carbonated natural spring water.", "Beverages", 25.00, 10, 20, null, 3, "Global Goods"));

        // 3. Initialize Alerts
        alerts.add(new Alert(1, "LOW_STOCK", 2, "Whole Milk (1L) is low on stock! Current: 3, Min required: 5", false, new Timestamp(System.currentTimeMillis())));
        alerts.add(new Alert(2, "LOW_STOCK", 5, "Fresh Salmon (500g) is low on stock! Current: 1, Min required: 5", false, new Timestamp(System.currentTimeMillis())));
        alerts.add(new Alert(3, "EXPIRED", 6, "Butter Croissants (4pk) is EXPIRED! Expiry: " + new Date(cal.getTimeInMillis()), false, new Timestamp(System.currentTimeMillis())));

        // 4. Initialize Transactions
        transactions.add(createDemoTransaction(1, 1, "STOCK_IN", 20, "Initial batch load"));
        transactions.add(createDemoTransaction(2, 2, "STOCK_IN", 5, "Replenishment"));
        transactions.add(createDemoTransaction(3, 5, "STOCK_OUT", 2, "Customer purchase"));
    }

    private static Product createDemoProduct(int id, String sku, String name, String description, String category, double price, int qty, int min, Date exp, int supId, String supName) {
        Product p = new Product(id, sku, name, description, category, price, qty, min, exp, supId);
        p.setSupplierName(supName);
        return p;
    }

    private static Transaction createDemoTransaction(int id, int prodId, String type, int qty, String notes) {
        Transaction t = new Transaction(id, prodId, -1, type, qty, new Timestamp(System.currentTimeMillis()), notes);
        t.setUserFullname("Demo User");
        for (Product p : products) {
            if (p.getId() == prodId) {
                t.setProductName(p.getName());
                t.setSku(p.getSku());
                break;
            }
        }
        return t;
    }

    // Suppliers API
    public static List<Supplier> getAllSuppliers() {
        return new ArrayList<>(suppliers);
    }

    public static Supplier getSupplierById(int id) {
        for (Supplier s : suppliers) {
            if (s.getId() == id) return s;
        }
        return null;
    }

    // Products API
    public static List<Product> getAllProducts() {
        return new ArrayList<>(products);
    }

    public static Product getProductById(int id) {
        for (Product p : products) {
            if (p.getId() == id) return p;
        }
        return null;
    }

    public static boolean addProduct(Product p) {
        p.setId(nextProductId++);
        p.setSupplierName(getSupplierName(p.getSupplierId()));
        products.add(p);

        // Auto-check for all alert types immediately
        checkProductAlerts(p);
        return true;
    }

    public static boolean updateProduct(Product p) {
        for (int i = 0; i < products.size(); i++) {
            if (products.get(i).getId() == p.getId()) {
                p.setSupplierName(getSupplierName(p.getSupplierId()));
                products.set(i, p);
                checkProductAlerts(p);
                return true;
            }
        }
        return false;
    }

    public static boolean deleteProduct(int id) {
        products.removeIf(p -> p.getId() == id);
        transactions.removeIf(t -> t.getProductId() == id);
        alerts.removeIf(a -> a.getProductId() == id);
        return true;
    }

    // Transactions API
    public static List<Transaction> getAllTransactions() {
        List<Transaction> list = new ArrayList<>(transactions);
        Collections.reverse(list);
        return list;
    }

    public static List<Transaction> getRecentTransactions(int limit) {
        List<Transaction> list = getAllTransactions();
        return list.subList(0, Math.min(limit, list.size()));
    }

    public static boolean addTransaction(Transaction t) {
        t.setId(nextTransactionId++);
        t.setTransactionDate(new Timestamp(System.currentTimeMillis()));
        t.setUserFullname("Demo User");
        
        Product p = getProductById(t.getProductId());
        if (p != null) {
            t.setProductName(p.getName());
            t.setSku(p.getSku());
            
            if ("STOCK_IN".equals(t.getType())) {
                p.setStockQuantity(p.getStockQuantity() + t.getQuantity());
            } else if ("STOCK_OUT".equals(t.getType())) {
                if (p.getStockQuantity() < t.getQuantity()) {
                    return false; // Insufficient stock
                }
                p.setStockQuantity(p.getStockQuantity() - t.getQuantity());
            }
            transactions.add(t);
            checkProductAlerts(p);
            return true;
        }
        return false;
    }

    // Alerts API
    public static List<Alert> getAllAlerts() {
        return new ArrayList<>(alerts);
    }

    /**
     * Inserts an alert if no unread alert of the same type+product already exists.
     * Used by AlertDAO to delegate in demo mode.
     */
    public static boolean addAlertIfNotExists(String type, int productId, String message) {
        for (Alert a : alerts) {
            if (a.getProductId() == productId && a.getType().equals(type) && !a.isRead()) {
                return false; // Already exists
            }
        }
        Alert a = new Alert(nextAlertId++, type, productId, message, false,
                new Timestamp(System.currentTimeMillis()));
        // Try to attach product name/sku for display
        Product p = getProductById(productId);
        if (p != null) {
            a.setProductName(p.getName());
            a.setSku(p.getSku());
        }
        alerts.add(a);
        return true;
    }

    public static boolean markAlertAsRead(int id) {
        for (Alert a : alerts) {
            if (a.getId() == id) {
                a.setRead(true);
                return true;
            }
        }
        return false;
    }

    // Dashboard Metrics
    public static Map<String, Integer> getDashboardMetrics() {
        Map<String, Integer> metrics = new HashMap<>();
        int lowStock = 0;
        int expired = 0;
        int nearExpiry = 0;

        Date today = new Date(System.currentTimeMillis());
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DATE, 30);
        Date thirtyDaysFromNow = new Date(cal.getTimeInMillis());

        for (Product p : products) {
            if (p.getStockQuantity() <= p.getMinStockLevel()) {
                lowStock++;
            }
            if (p.getExpiryDate() != null) {
                if (p.getExpiryDate().before(today)) {
                    expired++;
                } else if (p.getExpiryDate().before(thirtyDaysFromNow)) {
                    nearExpiry++;
                }
            }
        }

        metrics.put("total_products", products.size());
        metrics.put("low_stock", lowStock);
        metrics.put("expired", expired);
        metrics.put("near_expiry", nearExpiry);

        return metrics;
    }

    public static Map<String, Integer> getCategoryDistribution() {
        Map<String, Integer> dist = new HashMap<>();
        for (Product p : products) {
            dist.put(p.getCategory(), dist.getOrDefault(p.getCategory(), 0) + 1);
        }
        return dist;
    }

    // Helpers
    private static String getSupplierName(int id) {
        Supplier s = getSupplierById(id);
        return s != null ? s.getName() : "Unknown";
    }

    /**
     * Checks all alert types (Low Stock, Near Expiry, Expired) for a single product.
     * Removes stale alerts of each type before re-evaluating.
     */
    private static void checkProductAlerts(Product p) {
        java.time.LocalDate today = java.time.LocalDate.now();

        // --- Low Stock ---
        alerts.removeIf(a -> a.getProductId() == p.getId() && "LOW_STOCK".equals(a.getType()));
        if (p.getStockQuantity() <= p.getMinStockLevel()) {
            Alert a = new Alert(nextAlertId++, "LOW_STOCK", p.getId(),
                    p.getName() + " is low on stock! Current: " + p.getStockQuantity() + ", Min required: " + p.getMinStockLevel(),
                    false, new Timestamp(System.currentTimeMillis()));
            a.setProductName(p.getName());
            a.setSku(p.getSku());
            alerts.add(a);
        }

        // --- Expiry ---
        if (p.getExpiryDate() != null) {
            java.time.LocalDate expiry = p.getExpiryDate().toLocalDate();

            // Remove any existing NEAR_EXPIRY / EXPIRED alerts for re-evaluation
            alerts.removeIf(a -> a.getProductId() == p.getId()
                    && ("NEAR_EXPIRY".equals(a.getType()) || "EXPIRED".equals(a.getType())));

            if (expiry.isBefore(today)) {
                Alert a = new Alert(nextAlertId++, "EXPIRED", p.getId(),
                        "Product expired! " + p.getName() + " expired on " + p.getExpiryDate(),
                        false, new Timestamp(System.currentTimeMillis()));
                a.setProductName(p.getName());
                a.setSku(p.getSku());
                alerts.add(a);
            } else {
                long daysLeft = java.time.temporal.ChronoUnit.DAYS.between(today, expiry);
                if (daysLeft <= 30) {
                    Alert a = new Alert(nextAlertId++, "NEAR_EXPIRY", p.getId(),
                            "Product near expiry! " + p.getName() + " expires in " + daysLeft + " days ("
                                    + p.getExpiryDate() + ").",
                            false, new Timestamp(System.currentTimeMillis()));
                    a.setProductName(p.getName());
                    a.setSku(p.getSku());
                    alerts.add(a);
                }
            }
        }
    }
}
