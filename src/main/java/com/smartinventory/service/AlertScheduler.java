package com.smartinventory.service;

import com.smartinventory.dao.AlertDAO;
import com.smartinventory.dao.ProductDAO;
import com.smartinventory.model.Product;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class AlertScheduler implements ServletContextListener {
    private ScheduledExecutorService scheduler;
    private final ProductDAO productDAO = new ProductDAO();
    private static final AlertDAO alertDAO = new AlertDAO();

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[AlertScheduler] Initializing background task thread...");
        scheduler = Executors.newSingleThreadScheduledExecutor();
        
        // Run immediately on startup, and then once every 5 minutes for developer demonstration
        scheduler.scheduleAtFixedRate(this::checkInventoryAlerts, 0, 5, TimeUnit.MINUTES);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[AlertScheduler] Shutting down background task thread...");
        if (scheduler != null) {
            scheduler.shutdown();
        }
        System.out.println("[AlertScheduler] Closing HikariCP database connection pool...");
        com.smartinventory.util.ConnectionProvider.shutdown();
    }

    /**
     * Called by ProductServlet immediately after a product is added or updated
     * so alerts are raised right away — no need to wait for the next scheduler cycle.
     */
    public static void checkSingleProduct(Product p) {
        try {
            checkProductAlerts(p, alertDAO);
        } catch (Exception e) {
            System.err.println("[AlertScheduler] Immediate check failed for product " + p.getId() + ": " + e.getMessage());
        }
    }

    private void checkInventoryAlerts() {
        System.out.println("[AlertScheduler] Checking stock levels and expiry dates...");
        try {
            List<Product> products = productDAO.getAllProducts();
            LocalDate today = LocalDate.now();
            
            int lowStockCount = 0;
            int nearExpiryCount = 0;
            int expiredCount = 0;

            for (Product p : products) {
                int[] counts = checkProductAlerts(p, alertDAO);
                lowStockCount   += counts[0];
                nearExpiryCount += counts[1];
                expiredCount    += counts[2];
            }
            System.out.printf("[AlertScheduler] Scan finished. New alerts - Low Stock: %d, Near Expiry: %d, Expired: %d%n",
                    lowStockCount, nearExpiryCount, expiredCount);
        } catch (Exception e) {
            System.err.println("[AlertScheduler] Error occurred while running background checks: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Core alert logic for a single product. Returns [lowStock, nearExpiry, expired] counts.
     */
    private static int[] checkProductAlerts(Product p, AlertDAO alertDAO) {
        int lowStockCount = 0, nearExpiryCount = 0, expiredCount = 0;
        LocalDate today = LocalDate.now();

        // 1. Check Low Stock alert
        if (p.getStockQuantity() <= p.getMinStockLevel()) {
            String message = String.format("Product low stock! SKU: %s (%s) is at %d units (threshold: %d).",
                    p.getSku(), p.getName(), p.getStockQuantity(), p.getMinStockLevel());
            if (alertDAO.addAlertIfNotExists("LOW_STOCK", p.getId(), message)) {
                lowStockCount++;
                sendMockAlerts(p.getName(), "Low Stock Warning", message);
            }
        }

        // 2. Check Expiry Date alerts
        if (p.getExpiryDate() != null) {
            LocalDate expiry = p.getExpiryDate().toLocalDate();

            if (expiry.isBefore(today)) {
                // Already expired
                String message = String.format("Product expired! SKU: %s (%s) expired on %s.",
                        p.getSku(), p.getName(), p.getExpiryDate().toString());
                if (alertDAO.addAlertIfNotExists("EXPIRED", p.getId(), message)) {
                    expiredCount++;
                    sendMockAlerts(p.getName(), "Expired Inventory", message);
                }
            } else {
                // Near Expiry — expires within 30 days
                long daysUntilExpiry = ChronoUnit.DAYS.between(today, expiry);
                if (daysUntilExpiry <= 30) {
                    String message = String.format("Product near expiry! SKU: %s (%s) expires in %d days (%s).",
                            p.getSku(), p.getName(), daysUntilExpiry, p.getExpiryDate().toString());
                    if (alertDAO.addAlertIfNotExists("NEAR_EXPIRY", p.getId(), message)) {
                        nearExpiryCount++;
                        sendMockAlerts(p.getName(), "Near Expiry Alert", message);
                    }
                }
            }
        }
        return new int[]{lowStockCount, nearExpiryCount, expiredCount};
    }

    private static void sendMockAlerts(String productName, String alertSubject, String alertMessage) {
        // Log simulator simulating JavaMail SMTP and SMS triggers specified in Architecture Diagram
        System.out.println("========== [ALERT GATEWAY TRIGGERED] ==========");
        System.out.println("Channel 1 [EMAIL (JavaMail)]: Sent warning email to Manager.");
        System.out.println("   To: manager@smartinventory.com");
        System.out.println("   Subject: [SmartInventory] " + alertSubject + " - " + productName);
        System.out.println("   Content: " + alertMessage);
        System.out.println("Channel 2 [SMS (Gateway)]: Sent warning SMS to Manager.");
        System.out.println("   To: +91 99887 76655");
        System.out.println("   Message: [SmartInventory] " + alertSubject + ": " + alertMessage);
        System.out.println("===============================================");
    }
}
