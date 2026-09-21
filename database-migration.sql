-- ============================================
-- Database Migration Script
-- From: Supplier Management System
-- To: Order Management System
-- ============================================

-- Step 1: Create new database (if starting fresh)
CREATE DATABASE IF NOT EXISTS order_management_db;
USE order_management_db;

-- ============================================
-- OPTION A: Fresh Installation (No existing data)
-- ============================================

-- Drop existing tables if they exist
DROP TABLE IF EXISTS invoices;
DROP TABLE IF EXISTS vehicle_items;
DROP TABLE IF EXISTS purchase_orders;
DROP TABLE IF EXISTS customers;

-- Create customers table (renamed from suppliers)
CREATE TABLE customers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    contact_number VARCHAR(50),
    address VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create purchase_orders table
CREATE TABLE purchase_orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'NEW',
    tracking_number VARCHAR(100),
    total_amount DOUBLE,
    customer_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    INDEX idx_customer_id (customer_id),
    INDEX idx_status (status),
    INDEX idx_order_date (order_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create invoices table
CREATE TABLE invoices (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    amount DOUBLE NOT NULL,
    payment_status VARCHAR(50) DEFAULT 'PENDING',
    payment_date DATE,
    customer_id BIGINT NOT NULL,
    order_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES purchase_orders(id) ON DELETE SET NULL,
    INDEX idx_customer_id (customer_id),
    INDEX idx_payment_status (payment_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create vehicle_items table
CREATE TABLE vehicle_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(255) NOT NULL,
    quantity INT DEFAULT 1,
    unit_price DOUBLE,
    order_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES purchase_orders(id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert sample customer data
INSERT INTO customers (name, email, contact_number, address) VALUES
('John Doe', 'john.doe@example.com', '+1-555-0100', '123 Main Street, New York, NY'),
('Jane Smith', 'jane.smith@example.com', '+1-555-0101', '456 Oak Avenue, Los Angeles, CA'),
('Bob Johnson', 'bob.johnson@example.com', '+1-555-0102', '789 Pine Road, Chicago, IL');

-- Insert sample orders
INSERT INTO purchase_orders (order_date, status, tracking_number, total_amount, customer_id) VALUES
(CURDATE(), 'NEW', NULL, 1500.00, 1),
(DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'PROCESSING', 'TRK123456', 2300.00, 2),
(DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'SHIPPED', 'TRK789012', 890.00, 1),
(DATE_SUB(CURDATE(), INTERVAL 15 DAY), 'DELIVERED', 'TRK345678', 3200.00, 3);

-- Insert sample vehicle items
INSERT INTO vehicle_items (item_name, quantity, unit_price, order_id) VALUES
('Brake Pads', 4, 75.00, 1),
('Oil Filter', 2, 25.00, 1),
('Air Filter', 1, 45.00, 2),
('Spark Plugs', 8, 15.00, 2),
('Windshield Wipers', 2, 30.00, 3),
('Battery', 1, 150.00, 4);

-- Insert sample invoices
INSERT INTO invoices (amount, payment_status, payment_date, customer_id, order_id) VALUES
(1500.00, 'PENDING', NULL, 1, 1),
(2300.00, 'PAID', DATE_SUB(CURDATE(), INTERVAL 3 DAY), 2, 2),
(890.00, 'PAID', DATE_SUB(CURDATE(), INTERVAL 8 DAY), 1, 3),
(3200.00, 'PAID', DATE_SUB(CURDATE(), INTERVAL 12 DAY), 3, 4);

-- ============================================
-- OPTION B: Migration from Existing Database
-- ============================================
-- Use this if you have existing supplier_db data

/*
-- Switch to old database
USE supplier_db;

-- Rename tables
RENAME TABLE suppliers TO customers;
ALTER TABLE purchase_orders CHANGE COLUMN supplier_id customer_id BIGINT NOT NULL;
ALTER TABLE invoices CHANGE COLUMN supplier_id customer_id BIGINT NOT NULL;

-- Update foreign key constraints
ALTER TABLE purchase_orders DROP FOREIGN KEY purchase_orders_ibfk_1;
ALTER TABLE purchase_orders ADD CONSTRAINT fk_purchase_orders_customer 
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE;

ALTER TABLE invoices DROP FOREIGN KEY invoices_ibfk_1;
ALTER TABLE invoices ADD CONSTRAINT fk_invoices_customer 
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE;

-- Add indexes for better performance
CREATE INDEX idx_customer_id ON purchase_orders(customer_id);
CREATE INDEX idx_customer_id ON invoices(customer_id);
CREATE INDEX idx_status ON purchase_orders(status);
CREATE INDEX idx_payment_status ON invoices(payment_status);

-- Rename database (MySQL doesn't support direct rename, so we need to dump and restore)
-- Or simply update application.properties to point to supplier_db instead
*/

-- ============================================
-- Verification Queries
-- ============================================

-- Check customers
SELECT 'Customers Table' AS Info;
SELECT * FROM customers;

-- Check orders with customer names
SELECT 'Orders with Customer Names' AS Info;
SELECT 
    po.id,
    po.order_date,
    po.status,
    po.tracking_number,
    po.total_amount,
    c.name AS customer_name,
    c.email AS customer_email
FROM purchase_orders po
JOIN customers c ON po.customer_id = c.id
ORDER BY po.order_date DESC;

-- Check invoices with customer names
SELECT 'Invoices with Customer Names' AS Info;
SELECT 
    i.id,
    i.amount,
    i.payment_status,
    i.payment_date,
    c.name AS customer_name,
    po.id AS order_id
FROM invoices i
JOIN customers c ON i.customer_id = c.id
LEFT JOIN purchase_orders po ON i.order_id = po.id
ORDER BY i.id;

-- Check vehicle items
SELECT 'Vehicle Items' AS Info;
SELECT 
    vi.id,
    vi.item_name,
    vi.quantity,
    vi.unit_price,
    po.id AS order_id,
    c.name AS customer_name
FROM vehicle_items vi
JOIN purchase_orders po ON vi.order_id = po.id
JOIN customers c ON po.customer_id = c.id;

-- Summary statistics
SELECT 'Summary Statistics' AS Info;
SELECT 
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM purchase_orders) AS total_orders,
    (SELECT COUNT(*) FROM invoices) AS total_invoices,
    (SELECT COUNT(*) FROM vehicle_items) AS total_items,
    (SELECT SUM(total_amount) FROM purchase_orders) AS total_order_value,
    (SELECT SUM(amount) FROM invoices WHERE payment_status = 'PAID') AS total_paid_amount,
    (SELECT SUM(amount) FROM invoices WHERE payment_status = 'PENDING') AS total_pending_amount;
