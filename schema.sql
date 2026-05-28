-- Smart Inventory Control System Database Schema
CREATE DATABASE IF NOT EXISTS smart_inventory;
USE smart_inventory;

-- Drop tables if they exist (clean setup)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS alerts;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Users Table (Admin & Manager roles)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL, -- Stored as plaintext or hash (e.g. SHA-256)
    fullname VARCHAR(100) NOT NULL,
    role ENUM('ADMIN', 'MANAGER') NOT NULL,
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
    min_stock_level INT NOT NULL DEFAULT 5, -- Alert triggered when stock_quantity <= min_stock_level
    expiry_date DATE NULL,                  -- Expiry date for perishable inventory
    supplier_id INT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL
);

-- 4. Transactions Table (Stock In/Out Logs)
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

-- Insert Default Suppliers
INSERT INTO suppliers (name, contact_person, phone, email, address) VALUES
('Tech Corp India', 'Rajesh Kumar', '+91 98765 43210', 'sales@techcorp.in', 'Tech Park, Bangalore'),
('Apex Logistics', 'Sunita Sharma', '+91 91234 56789', 'contact@apexlogistics.com', 'Sector 62, Noida'),
('Global BioPharm', 'Dr. Anil Mehta', '+91 99887 76655', 'supply@biopharm.com', 'Industrial Area, Hyderabad');

-- Insert Default Users (Password matches username for local convenience)
INSERT INTO users (username, password, fullname, role, email) VALUES
('admin', 'admin123', 'Administrator', 'ADMIN', 'admin@smartinventory.com'),
('manager', 'manager123', 'Inventory Manager', 'MANAGER', 'manager@smartinventory.com');

-- Insert Default Products (Some with low stock or near expiry to demonstrate alerts)
INSERT INTO products (sku, name, description, category, price, stock_quantity, min_stock_level, expiry_date, supplier_id) VALUES
-- Admin & Manager Demo Products
('SKU-LAP-001', 'Enterprise Laptop 15"', 'High-performance laptop for enterprise developers.', 'Electronics', 75000.00, 15, 3, NULL, 1),
('SKU-PHN-002', 'Smart Phone 5G', 'Latest generation Android smartphone.', 'Electronics', 25000.00, 2, 5, NULL, 1), -- Low stock alert triggers (2 <= 5)
('SKU-MED-003', 'Amoxicillin 500mg', 'Antibiotic capsules, 100 pack.', 'Pharmaceuticals', 450.00, 50, 10, '2026-06-15', 3), -- Near expiry alert triggers (expires in < 30 days from May 2026)
('SKU-MED-004', 'Vitamins Multi-Pack', 'Daily multivitamin dietary supplement.', 'Pharmaceuticals', 600.00, 30, 5, '2026-04-10', 3), -- Expired alert triggers (expires in past)
('SKU-OFC-005', 'Ergonomic Desk Chair', 'Mesh back adjustable office chair.', 'Office Supplies', 8500.00, 8, 2, NULL, 2);

-- Insert Sample Transaction Log
INSERT INTO transactions (product_id, user_id, type, quantity, notes) VALUES
(1, 1, 'STOCK_IN', 15, 'Initial stock import by Admin'),
(2, 1, 'STOCK_IN', 5, 'Initial stock import by Admin'),
(2, 2, 'STOCK_OUT', 3, 'Dispatched 3 units to Noida office'),
(3, 1, 'STOCK_IN', 50, 'Procured pharmaceuticals batch'),
(4, 1, 'STOCK_IN', 30, 'Procured vitamins batch'),
(5, 1, 'STOCK_IN', 8, 'Initial stock import');
