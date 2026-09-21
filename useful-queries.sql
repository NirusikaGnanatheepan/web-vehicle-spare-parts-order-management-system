-- ============================================
-- Useful Queries for Order Management System
-- ============================================

USE order_management_db;

-- ============================================
-- CUSTOMER QUERIES
-- ============================================

-- Get all customers
SELECT * FROM customers ORDER BY name;

-- Get customer with their order count
SELECT 
    c.id,
    c.name,
    c.email,
    c.contact_number,
    COUNT(po.id) AS total_orders,
    COALESCE(SUM(po.total_amount), 0) AS total_spent
FROM customers c
LEFT JOIN purchase_orders po ON c.id = po.customer_id
GROUP BY c.id, c.name, c.email, c.contact_number
ORDER BY total_spent DESC;

-- Get top 5 customers by order value
SELECT 
    c.name,
    c.email,
    COUNT(po.id) AS order_count,
    SUM(po.total_amount) AS total_value
FROM customers c
JOIN purchase_orders po ON c.id = po.customer_id
GROUP BY c.id, c.name, c.email
ORDER BY total_value DESC
LIMIT 5;

-- Get customers with pending payments
SELECT DISTINCT
    c.id,
    c.name,
    c.email,
    c.contact_number,
    COUNT(i.id) AS pending_invoices,
    SUM(i.amount) AS pending_amount
FROM customers c
JOIN invoices i ON c.id = i.customer_id
WHERE i.payment_status = 'PENDING'
GROUP BY c.id, c.name, c.email, c.contact_number
ORDER BY pending_amount DESC;

-- ============================================
-- ORDER QUERIES
-- ============================================

-- Get all orders with customer details
SELECT 
    po.id AS order_id,
    po.order_date,
    po.status,
    po.tracking_number,
    po.total_amount,
    c.name AS customer_name,
    c.email AS customer_email,
    c.contact_number
FROM purchase_orders po
JOIN customers c ON po.customer_id = c.id
ORDER BY po.order_date DESC;

-- Get orders by status
SELECT 
    status,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_value
FROM purchase_orders
GROUP BY status
ORDER BY order_count DESC;

-- Get orders for a specific customer (replace 1 with customer_id)
SELECT 
    po.id,
    po.order_date,
    po.status,
    po.tracking_number,
    po.total_amount
FROM purchase_orders po
WHERE po.customer_id = 1
ORDER BY po.order_date DESC;

-- Get recent orders (last 30 days)
SELECT 
    po.id,
    po.order_date,
    po.status,
    c.name AS customer_name,
    po.total_amount
FROM purchase_orders po
JOIN customers c ON po.customer_id = c.id
WHERE po.order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY po.order_date DESC;

-- Get orders with items
SELECT 
    po.id AS order_id,
    po.order_date,
    c.name AS customer_name,
    vi.item_name,
    vi.quantity,
    vi.unit_price,
    (vi.quantity * vi.unit_price) AS item_total
FROM purchase_orders po
JOIN customers c ON po.customer_id = c.id
LEFT JOIN vehicle_items vi ON po.id = vi.order_id
ORDER BY po.id, vi.id;

-- Get orders without tracking numbers
SELECT 
    po.id,
    po.order_date,
    po.status,
    c.name AS customer_name,
    po.total_amount
FROM purchase_orders po
JOIN customers c ON po.customer_id = c.id
WHERE po.tracking_number IS NULL OR po.tracking_number = ''
ORDER BY po.order_date DESC;

-- ============================================
-- INVOICE/PAYMENT QUERIES
-- ============================================

-- Get all invoices with customer and order details
SELECT 
    i.id AS invoice_id,
    i.amount,
    i.payment_status,
    i.payment_date,
    c.name AS customer_name,
    c.email AS customer_email,
    po.id AS order_id,
    po.order_date
FROM invoices i
JOIN customers c ON i.customer_id = c.id
LEFT JOIN purchase_orders po ON i.order_id = po.id
ORDER BY i.id DESC;

-- Get pending invoices
SELECT 
    i.id,
    i.amount,
    c.name AS customer_name,
    c.email,
    c.contact_number,
    po.order_date,
    DATEDIFF(CURDATE(), po.order_date) AS days_pending
FROM invoices i
JOIN customers c ON i.customer_id = c.id
LEFT JOIN purchase_orders po ON i.order_id = po.id
WHERE i.payment_status = 'PENDING'
ORDER BY days_pending DESC;

-- Get paid invoices in date range
SELECT 
    i.id,
    i.amount,
    i.payment_date,
    c.name AS customer_name
FROM invoices i
JOIN customers c ON i.customer_id = c.id
WHERE i.payment_status = 'PAID'
  AND i.payment_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 30 DAY) AND CURDATE()
ORDER BY i.payment_date DESC;

-- Get payment summary by customer
SELECT 
    c.name AS customer_name,
    COUNT(i.id) AS total_invoices,
    SUM(CASE WHEN i.payment_status = 'PAID' THEN i.amount ELSE 0 END) AS paid_amount,
    SUM(CASE WHEN i.payment_status = 'PENDING' THEN i.amount ELSE 0 END) AS pending_amount,
    SUM(i.amount) AS total_amount
FROM customers c
LEFT JOIN invoices i ON c.id = i.customer_id
GROUP BY c.id, c.name
ORDER BY total_amount DESC;

-- ============================================
-- VEHICLE ITEMS QUERIES
-- ============================================

-- Get all items with order and customer info
SELECT 
    vi.id,
    vi.item_name,
    vi.quantity,
    vi.unit_price,
    (vi.quantity * vi.unit_price) AS total_price,
    po.id AS order_id,
    c.name AS customer_name
FROM vehicle_items vi
JOIN purchase_orders po ON vi.order_id = po.id
JOIN customers c ON po.customer_id = c.id
ORDER BY vi.id;

-- Get most ordered items
SELECT 
    item_name,
    SUM(quantity) AS total_quantity,
    COUNT(*) AS order_count,
    AVG(unit_price) AS avg_price
FROM vehicle_items
GROUP BY item_name
ORDER BY total_quantity DESC;

-- Get items for a specific order (replace 1 with order_id)
SELECT 
    item_name,
    quantity,
    unit_price,
    (quantity * unit_price) AS total
FROM vehicle_items
WHERE order_id = 1;

-- ============================================
-- ANALYTICS & REPORTS
-- ============================================

-- Monthly order summary
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_order_value
FROM purchase_orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month DESC;

-- Daily order summary (last 7 days)
SELECT 
    DATE(order_date) AS order_day,
    COUNT(*) AS orders,
    SUM(total_amount) AS revenue
FROM purchase_orders
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY DATE(order_date)
ORDER BY order_day DESC;

-- Order status distribution
SELECT 
    status,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM purchase_orders), 2) AS percentage
FROM purchase_orders
GROUP BY status
ORDER BY count DESC;

-- Payment status summary
SELECT 
    payment_status,
    COUNT(*) AS invoice_count,
    SUM(amount) AS total_amount,
    ROUND(AVG(amount), 2) AS avg_amount
FROM invoices
GROUP BY payment_status;

-- Revenue by customer (top 10)
SELECT 
    c.name,
    COUNT(po.id) AS order_count,
    SUM(po.total_amount) AS total_revenue,
    AVG(po.total_amount) AS avg_order_value
FROM customers c
JOIN purchase_orders po ON c.id = po.customer_id
GROUP BY c.id, c.name
ORDER BY total_revenue DESC
LIMIT 10;

-- ============================================
-- MAINTENANCE QUERIES
-- ============================================

-- Delete a customer and all related data (CASCADE will handle it)
-- DELETE FROM customers WHERE id = ?;

-- Update order status
-- UPDATE purchase_orders SET status = 'SHIPPED', tracking_number = 'TRK123456' WHERE id = ?;

-- Mark invoice as paid
-- UPDATE invoices SET payment_status = 'PAID', payment_date = CURDATE() WHERE id = ?;

-- Update customer information
-- UPDATE customers SET email = 'newemail@example.com', contact_number = '+1-555-9999' WHERE id = ?;

-- ============================================
-- BACKUP QUERIES
-- ============================================

-- Create backup of customers
CREATE TABLE customers_backup AS SELECT * FROM customers;

-- Create backup of orders
CREATE TABLE purchase_orders_backup AS SELECT * FROM purchase_orders;

-- Restore from backup (if needed)
-- TRUNCATE TABLE customers;
-- INSERT INTO customers SELECT * FROM customers_backup;

-- ============================================
-- CLEANUP QUERIES
-- ============================================

-- Delete old completed orders (older than 1 year)
-- DELETE FROM purchase_orders 
-- WHERE status = 'DELIVERED' 
--   AND order_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- Delete paid invoices older than 2 years
-- DELETE FROM invoices 
-- WHERE payment_status = 'PAID' 
--   AND payment_date < DATE_SUB(CURDATE(), INTERVAL 2 YEAR);
