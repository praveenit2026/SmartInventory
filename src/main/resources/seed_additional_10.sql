-- ==========================================================
-- Sample data for Smart Inventory - 10 Additional Products
-- ==========================================================

INSERT INTO products (sku, name, description, category, price, stock_quantity, min_stock_level, expiry_date, supplier_id) VALUES
('SKU031', 'Organic Strawberries (250g)', 'Sweet fresh organic strawberries.', 'Fresh Produce', 180.00, 12, 5, DATE_ADD(CURDATE(), INTERVAL 4 DAY), 1),
('SKU032', 'Cheddar Cheese (200g)', 'Aged sharp white cheddar cheese.', 'Dairy & Eggs', 160.00, 4, 10, DATE_ADD(CURDATE(), INTERVAL 14 DAY), 2),
('SKU033', 'Ribeye Steak (300g)', 'Premium grain-fed beef ribeye steak.', 'Meat & Seafood', 450.00, 8, 5, DATE_ADD(CURDATE(), INTERVAL 3 DAY), 1),
('SKU034', 'Hot Dog Buns (6pk)', 'Soft white hot dog buns.', 'Bakery & Bread', 60.00, 25, 10, DATE_ADD(CURDATE(), INTERVAL 5 DAY), 2),
('SKU035', 'Energy Drink (250ml)', 'Taurine and caffeine energy boost drink.', 'Beverages', 110.00, 60, 15, NULL, 3),
('SKU036', 'Mixed Nuts (200g)', 'Salted almonds, cashews, and walnuts.', 'Snacks & Confectionery', 240.00, 3, 8, DATE_ADD(CURDATE(), INTERVAL 90 DAY), 3),
('SKU037', 'Frozen Chicken Nuggets', 'Crispy breaded chicken nuggets.', 'Frozen Foods', 180.00, 15, 5, DATE_ADD(CURDATE(), INTERVAL 45 DAY), 3),
('SKU038', 'Canned Sweet Corn', 'Sweet kernel corn in water.', 'Canned & Packaged', 55.00, 40, 15, DATE_ADD(CURDATE(), INTERVAL 240 DAY), 3),
('SKU039', 'Jasmine Rice (5kg)', 'Fragrant Thai jasmine white rice.', 'Grains & Pulses', 480.00, 18, 5, NULL, 3),
('SKU040', 'Hand Sanitizer (100ml)', '70% ethyl alcohol sanitizing gel.', 'Personal Care', 45.00, 0, 20, NULL, 3);
