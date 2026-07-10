-- =====================================================================
-- Smart Inventory Control System — Full Database Init Script
-- Run this ONCE on your external MySQL database (Aiven / Railway / etc.)
-- =====================================================================

-- Create the database (skip if your host pre-creates it)
CREATE DATABASE IF NOT EXISTS smart_inventory CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE smart_inventory;

-- Drop tables if they exist (clean setup)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS alerts;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Users Table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    fullname VARCHAR(100) NOT NULL,
    role ENUM('ADMIN', 'MANAGER', 'DEMO') NOT NULL,
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Suppliers Table
CREATE TABLE suppliers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT
);

-- 3. Products Table
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    min_stock_level INT NOT NULL DEFAULT 5,
    expiry_date DATE NULL,
    supplier_id INT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL
);

-- 4. Transactions Table
CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    type ENUM('STOCK_IN', 'STOCK_OUT') NOT NULL,
    quantity INT NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 5. Alerts Table
CREATE TABLE alerts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type ENUM('LOW_STOCK', 'NEAR_EXPIRY', 'EXPIRED') NOT NULL,
    product_id INT NOT NULL,
    message VARCHAR(255) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- ── Seed Data ─────────────────────────────────────────────────────────

INSERT INTO suppliers (name, contact_person, phone, email, address) VALUES
('FreshFarms Co', 'Rajesh Kumar', '+91 98765 43210', 'sales@freshfarms.in', 'Tech Park, Bangalore'),
('Apex Dairy Ltd', 'Sunita Sharma', '+91 91234 56789', 'contact@apexdairy.com', 'Sector 62, Noida'),
('Global Goods', 'Anil Mehta', '+91 99887 76655', 'supply@globalgoods.com', 'Industrial Area, Hyderabad');

INSERT INTO users (username, password, fullname, role, email) VALUES
('admin', 'admin123', 'Administrator', 'ADMIN', 'admin@smartinventory.com'),
('manager', 'manager123', 'Inventory Manager', 'MANAGER', 'manager@smartinventory.com'),
('demo', 'demo123', 'Demo User', 'DEMO', 'demo@smartinventory.com');

INSERT INTO products (sku, name, description, category, price, stock_quantity, min_stock_level, expiry_date, supplier_id) VALUES
('SKU001', 'Organic Apples (1kg)', 'Crisp organic red apples.', 'Fresh Produce', 150.00, 20, 5, DATE_ADD(CURDATE(), INTERVAL 10 DAY), 1),
('SKU002', 'Whole Milk (1L)', 'Full-fat pasteurized cow milk.', 'Dairy & Eggs', 60.00, 3, 5, DATE_ADD(CURDATE(), INTERVAL 6 DAY), 2),
('SKU003', 'Brown Eggs (12pk)', 'Free-range large brown eggs.', 'Dairy & Eggs', 120.00, 35, 10, DATE_ADD(CURDATE(), INTERVAL 15 DAY), 2),
('SKU004', 'Chicken Breast (1kg)', 'Fresh boneless chicken breast.', 'Meat & Seafood', 350.00, 15, 8, DATE_ADD(CURDATE(), INTERVAL 4 DAY), 1),
('SKU005', 'Fresh Salmon (500g)', 'Wild caught Atlantic salmon.', 'Meat & Seafood', 500.00, 1, 5, DATE_ADD(CURDATE(), INTERVAL 2 DAY), 1),
('SKU006', 'Sourdough Bread', 'Freshly baked artisanal sourdough loaf.', 'Bakery & Bread', 90.00, 12, 5, DATE_ADD(CURDATE(), INTERVAL 3 DAY), 2),
('SKU007', 'Butter Croissants (4pk)', 'Flaky buttery bakery croissants.', 'Bakery & Bread', 110.00, 2, 5, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 2),
('SKU008', 'Coca-Cola (1.25L)', 'Classic carbonated soft drink.', 'Beverages', 45.00, 50, 15, NULL, 3),
('SKU009', 'Sparkling Water (500ml)', 'Carbonated natural spring water.', 'Beverages', 25.00, 10, 20, NULL, 3),
('SKU010', 'Dark Chocolate (100g)', '70% cocoa rich dark chocolate.', 'Snacks & Confectionery', 80.00, 45, 10, DATE_ADD(CURDATE(), INTERVAL 180 DAY), 3),
('SKU011', 'Potato Chips (150g)', 'Classic salted crispy chips.', 'Snacks & Confectionery', 50.00, 60, 15, DATE_ADD(CURDATE(), INTERVAL 90 DAY), 3),
('SKU012', 'Frozen Peas (500g)', 'Sweet green peas, IQF frozen.', 'Frozen Foods', 75.00, 25, 8, DATE_ADD(CURDATE(), INTERVAL 120 DAY), 3),
('SKU013', 'Frozen Pepperoni Pizza', 'Stone baked pepperoni pizza.', 'Frozen Foods', 220.00, 4, 10, DATE_ADD(CURDATE(), INTERVAL 60 DAY), 3),
('SKU014', 'Canned Tomato Paste', 'Double concentrated tomato paste.', 'Canned & Packaged', 40.00, 80, 20, DATE_ADD(CURDATE(), INTERVAL 365 DAY), 3),
('SKU015', 'Canned Tuna in Oil', 'Premium solid light tuna.', 'Canned & Packaged', 95.00, 120, 30, DATE_ADD(CURDATE(), INTERVAL 500 DAY), 3),
('SKU016', 'Basmati Rice (1kg)', 'Aged long-grain aromatic basmati rice.', 'Grains & Pulses', 110.00, 40, 10, NULL, 3),
('SKU017', 'Red Lentils (1kg)', 'Split red lentils, high in protein.', 'Grains & Pulses', 85.00, 3, 10, NULL, 3),
('SKU018', 'Dishwashing Liquid', 'Lemon fresh grease cutting dish soap.', 'Cleaning & Household', 120.00, 30, 8, NULL, 3),
('SKU019', 'Laundry Detergent (1L)', 'Concentrated liquid detergent.', 'Cleaning & Household', 250.00, 15, 5, NULL, 3),
('SKU020', 'Herbal Shampoo (400ml)', 'Nourishing aloe vera shampoo.', 'Personal Care', 180.00, 20, 5, NULL, 3),
('SKU021', 'Mint Toothpaste (150g)', 'Fluoride toothpaste for fresh breath.', 'Personal Care', 65.00, 0, 10, NULL, 3),
('SKU022', 'Baby Wipes (80pk)', 'Fragrance-free sensitive baby wipes.', 'Baby Products', 110.00, 35, 10, NULL, 3),
('SKU023', 'Baby Diapers (Large)', 'Ultra-absorbent baby diapers.', 'Baby Products', 600.00, 8, 15, NULL, 3),
('SKU024', 'Bananas (1 Dozen)', 'Fresh yellow sweet bananas.', 'Fresh Produce', 60.00, 18, 5, DATE_ADD(CURDATE(), INTERVAL 5 DAY), 1),
('SKU025', 'Greek Yogurt (500g)', 'Thick and creamy Greek yogurt.', 'Dairy & Eggs', 140.00, 8, 10, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 2),
('SKU031', 'Organic Strawberries (250g)', 'Sweet fresh organic strawberries.', 'Fresh Produce', 180.00, 12, 5, DATE_ADD(CURDATE(), INTERVAL 4 DAY), 1),
('SKU032', 'Cheddar Cheese (200g)', 'Aged sharp white cheddar cheese.', 'Dairy & Eggs', 160.00, 4, 10, DATE_ADD(CURDATE(), INTERVAL 14 DAY), 2),
('SKU033', 'Ribeye Steak (300g)', 'Premium grain-fed beef ribeye steak.', 'Meat & Seafood', 450.00, 8, 5, DATE_ADD(CURDATE(), INTERVAL 3 DAY), 1),
('SKU034', 'Hot Dog Buns (6pk)', 'Soft white hot dog buns.', 'Bakery & Bread', 60.00, 25, 10, DATE_ADD(CURDATE(), INTERVAL 5 DAY), 2),
('SKU035', 'Energy Drink (250ml)', 'Taurine and caffeine energy drink.', 'Beverages', 110.00, 60, 15, NULL, 3),
('SKU036', 'Mixed Nuts (200g)', 'Salted almonds cashews walnuts.', 'Snacks & Confectionery', 240.00, 3, 8, DATE_ADD(CURDATE(), INTERVAL 90 DAY), 3),
('SKU037', 'Frozen Chicken Nuggets', 'Crispy breaded chicken nuggets.', 'Frozen Foods', 180.00, 15, 5, DATE_ADD(CURDATE(), INTERVAL 45 DAY), 3),
('SKU038', 'Canned Sweet Corn', 'Sweet kernel corn in water.', 'Canned & Packaged', 55.00, 40, 15, DATE_ADD(CURDATE(), INTERVAL 240 DAY), 3),
('SKU039', 'Jasmine Rice (5kg)', 'Fragrant Thai jasmine white rice.', 'Grains & Pulses', 480.00, 18, 5, NULL, 3),
('SKU040', 'Hand Sanitizer (100ml)', '70% ethyl alcohol sanitizing gel.', 'Personal Care', 45.00, 0, 20, NULL, 3);
