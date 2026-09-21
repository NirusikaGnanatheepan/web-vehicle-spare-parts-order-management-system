-- ============================================
-- Advanced Reports & Analytics Queries
-- Order Management System
-- ============================================

USE order_management_db;

-- ============================================
-- CUSTOMER ANALYTICS
-- ============================================

-- Customer Lifetime Value (CLV)
SELECT 
    c.id,
    c.name,
    c.email,
    COUNT(DISTINCT po.id) AS total_orders,
    COALESCE(SUM(po.total_amount), 0) AS lifetime_value,
    COALESCE(AVG(po.total_amount), 0) AS avg_order_value,
    MIN(po.order_date) AS first_order_date,
    MAX(po.order_date) AS last_order_date,
    DATEDIFF(MAX(po.order_date), MIN(po.order_date)) AS customer_age_days
FROM customers c
LEFT JOIN purchase_orders po ON c.id = po.customer_id
GROUP BY c.id, c.name, c.email
ORDER BY lifetime_value DESC;

-- Customer Segmentation (RFM Analysis)
SELECT 
    c.id,
    c.name,
    DATEDIFF(CURDATE(), MAX(po.order_date)) AS recency_days,
    COUNT(po.id) AS frequency,
    COALESCE(SUM(po.total_amount), 0) AS monetary_value,
    CASE 
        WHEN DATEDIFF(CURDATE(), MAX(po.order_date)) <= 30 THEN 'Active'
        WHEN DATEDIFF(CURDATE(), MAX(po.order_date)) <= 90 THEN 'At Risk'
        WHEN DATEDIFF(CURDATE(), MAX(po.order_date)) <= 180 THEN 'Dormant'
        ELSE 'Lost'
    END AS customer_status
FROM customers c
LEFT JOIN purchase_orders po ON c.id = po.customer_id
GROUP BY c.id, c.name
ORDER BY monetary_value DESC;

-- Customer Purchase Frequency
SELECT 
    c.name,
    COUNT(po.id) AS order_count,
    ROUND(AVG(DATEDIFF(
        LEAD(po.order_date) OVER (PARTITION BY c.id ORDER BY po.order_date),
        po.order_date
    )), 0) AS avg_days_between_orders
FROM customers c
JOIN purchase_orders po ON c.id = po.customer_id
GROUP BY c.id, c.name
HAVING order_count > 1
ORDER BY order_count DESC;

-- ============================================
-- SALES ANALYTICS
-- ============================================

-- Daily Sales Report
SELECT 
    DATE(order_date) AS sale_date,
    COUNT(*) AS orders_count,
    SUM(total_amount) AS daily_revenue,
    AVG(total_amount) AS avg_order_value,
    MIN(total_amount) AS min_order,
    MAX(total_amount) AS max_order
FROM purchase_orders
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY DATE(order_date)
ORDER BY sale_date DESC;

-- Weekly Sales Trend
SELECT 
    YEARWEEK(order_date) AS year_week,
    DATE(DATE_SUB(order_date, INTERVAL WEEKDAY(order_date) DAY)) AS week_start,
    COUNT(*) AS orders,
    SUM(total_amount) AS weekly_revenue,
    AVG(total_amount) AS avg_order_value
FROM purchase_orders
GROUP BY YEARWEEK(order_date), DATE(DATE_SUB(order_date, INTERVAL WEEKDAY(order_date) DAY))
ORDER BY year_week DESC
LIMIT 12;

-- Monthly Sales Comparison (Year over Year)
SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    DATE_FORMAT(order_date, '%Y-%m') AS period,
    COUNT(*) AS orders,
    SUM(total_amount) AS revenue,
    AVG(total_amount) AS avg_order
FROM purchase_orders
GROUP BY YEAR(order_date), MONTH(order_date), DATE_FORMAT(order_date, '%Y-%m')
ORDER BY year DESC, month DESC;

-- Sales by Order Status
SELECT 
    status,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_order_value,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM purchase_orders), 2) AS percentage
FROM purchase_orders
GROUP BY status
ORDER BY total_revenue DESC;

-- ============================================
-- PRODUCT/ITEM ANALYTICS
-- ============================================

-- Top Selling Items
SELECT 
    vi.item_name,
    COUNT(DISTINCT vi.order_id) AS times_ordered,
    SUM(vi.quantity) AS total_quantity_sold,
    ROUND(AVG(vi.unit_price), 2) AS avg_price,
    ROUND(SUM(vi.quantity * vi.unit_price), 2) AS total_revenue
FROM vehicle_items vi
GROUP BY vi.item_name
ORDER BY total_revenue DESC;

-- Item Performance by Month
SELECT 
    vi.item_name,
    DATE_FORMAT(po.order_date, '%Y-%m') AS month,
    SUM(vi.quantity) AS quantity_sold,
    SUM(vi.quantity * vi.unit_price) AS revenue
FROM vehicle_items vi
JOIN purchase_orders po ON vi.order_id = po.id
GROUP BY vi.item_name, DATE_FORMAT(po.order_date, '%Y-%m')
ORDER BY month DESC, revenue DESC;

-- Items Never Ordered
SELECT DISTINCT item_name
FROM vehicle_items
WHERE item_name NOT IN (
    SELECT DISTINCT item_name 
    FROM vehicle_items 
    WHERE order_id IS NOT NULL
);

-- Average Items per Order
SELECT 
    AVG(item_count) AS avg_items_per_order,
    MIN(item_count) AS min_items,
    MAX(item_count) AS max_items
FROM (
    SELECT order_id, COUNT(*) AS item_count
    FROM vehicle_items
    GROUP BY order_id
) AS order_items;

-- ============================================
-- PAYMENT ANALYTICS
-- ============================================

-- Payment Collection Rate
SELECT 
    COUNT(*) AS total_invoices,
    SUM(CASE WHEN payment_status = 'PAID' THEN 1 ELSE 0 END) AS paid_invoices,
    SUM(CASE WHEN payment_status = 'PENDING' THEN 1 ELSE 0 END) AS pending_invoices,
    ROUND(SUM(CASE WHEN payment_status = 'PAID' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS collection_rate_percent,
    SUM(amount) AS total_invoiced,
    SUM(CASE WHEN payment_status = 'PAID' THEN amount ELSE 0 END) AS total_collected,
    SUM(CASE WHEN payment_status = 'PENDING' THEN amount ELSE 0 END) AS total_outstanding
FROM invoices;

-- Aging Report (Outstanding Invoices)
SELECT 
    i.id,
    c.name AS customer_name,
    i.amount,
    po.order_date,
    DATEDIFF(CURDATE(), po.order_date) AS days_outstanding,
    CASE 
        WHEN DATEDIFF(CURDATE(), po.order_date) <= 30 THEN '0-30 days'
        WHEN DATEDIFF(CURDATE(), po.order_date) <= 60 THEN '31-60 days'
        WHEN DATEDIFF(CURDATE(), po.order_date) <= 90 THEN '61-90 days'
        ELSE '90+ days'
    END AS aging_bucket
FROM invoices i
JOIN customers c ON i.customer_id = c.id
LEFT JOIN purchase_orders po ON i.order_id = po.id
WHERE i.payment_status = 'PENDING'
ORDER BY days_outstanding DESC;

-- Payment Collection by Month
SELECT 
    DATE_FORMAT(payment_date, '%Y-%m') AS month,
    COUNT(*) AS payments_received,
    SUM(amount) AS total_collected,
    AVG(amount) AS avg_payment
FROM invoices
WHERE payment_status = 'PAID' AND payment_date IS NOT NULL
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY month DESC;

-- Average Days to Payment
SELECT 
    ROUND(AVG(DATEDIFF(i.payment_date, po.order_date)), 0) AS avg_days_to_payment,
    MIN(DATEDIFF(i.payment_date, po.order_date)) AS fastest_payment,
    MAX(DATEDIFF(i.payment_date, po.order_date)) AS slowest_payment
FROM invoices i
JOIN purchase_orders po ON i.order_id = po.id
WHERE i.payment_status = 'PAID' AND i.payment_date IS NOT NULL;

-- ============================================
-- ORDER FULFILLMENT ANALYTICS
-- ============================================

-- Order Processing Time by Status
SELECT 
    status,
    COUNT(*) AS order_count,
    ROUND(AVG(DATEDIFF(CURDATE(), order_date)), 0) AS avg_days_in_status
FROM purchase_orders
GROUP BY status
ORDER BY avg_days_in_status DESC;

-- Orders Stuck in Processing
SELECT 
    po.id,
    po.order_date,
    po.status,
    c.name AS customer_name,
    po.total_amount,
    DATEDIFF(CURDATE(), po.order_date) AS days_since_order
FROM purchase_orders po
JOIN customers c ON po.customer_id = c.id
WHERE po.status IN ('NEW', 'PROCESSING')
  AND DATEDIFF(CURDATE(), po.order_date) > 7
ORDER BY days_since_order DESC;

-- Delivery Success Rate
SELECT 
    COUNT(*) AS total_orders,
    SUM(CASE WHEN status = 'DELIVERED' THEN 1 ELSE 0 END) AS delivered_orders,
    ROUND(SUM(CASE WHEN status = 'DELIVERED' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delivery_rate_percent
FROM purchase_orders
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY);

-- ============================================
-- COHORT ANALYSIS
-- ============================================

-- Customer Cohort by First Order Month
SELECT 
    DATE_FORMAT(first_order_date, '%Y-%m') AS cohort_month,
    COUNT(DISTINCT customer_id) AS customers,
    SUM(total_orders) AS total_orders,
    SUM(total_spent) AS total_revenue,
    ROUND(AVG(total_spent), 2) AS avg_customer_value
FROM (
    SELECT 
        c.id AS customer_id,
        MIN(po.order_date) AS first_order_date,
        COUNT(po.id) AS total_orders,
        SUM(po.total_amount) AS total_spent
    FROM customers c
    JOIN purchase_orders po ON c.id = po.customer_id
    GROUP BY c.id
) AS customer_cohorts
GROUP BY DATE_FORMAT(first_order_date, '%Y-%m')
ORDER BY cohort_month DESC;

-- ============================================
-- EXECUTIVE DASHBOARD SUMMARY
-- ============================================

-- Key Performance Indicators (KPIs)
SELECT 
    'Total Customers' AS metric,
    COUNT(*) AS value,
    NULL AS percentage
FROM customers

UNION ALL

SELECT 
    'Total Orders',
    COUNT(*),
    NULL
FROM purchase_orders

UNION ALL

SELECT 
    'Total Revenue',
    ROUND(SUM(total_amount), 2),
    NULL
FROM purchase_orders

UNION ALL

SELECT 
    'Average Order Value',
    ROUND(AVG(total_amount), 2),
    NULL
FROM purchase_orders

UNION ALL

SELECT 
    'Orders This Month',
    COUNT(*),
    NULL
FROM purchase_orders
WHERE YEAR(order_date) = YEAR(CURDATE()) 
  AND MONTH(order_date) = MONTH(CURDATE())

UNION ALL

SELECT 
    'Revenue This Month',
    ROUND(SUM(total_amount), 2),
    NULL
FROM purchase_orders
WHERE YEAR(order_date) = YEAR(CURDATE()) 
  AND MONTH(order_date) = MONTH(CURDATE())

UNION ALL

SELECT 
    'Pending Invoices',
    COUNT(*),
    NULL
FROM invoices
WHERE payment_status = 'PENDING'

UNION ALL

SELECT 
    'Outstanding Amount',
    ROUND(SUM(amount), 2),
    NULL
FROM invoices
WHERE payment_status = 'PENDING'

UNION ALL

SELECT 
    'Collection Rate',
    NULL,
    ROUND(SUM(CASE WHEN payment_status = 'PAID' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM invoices;

-- ============================================
-- GROWTH METRICS
-- ============================================

-- Month-over-Month Growth
WITH monthly_sales AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(total_amount) AS revenue
    FROM purchase_orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT 
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month) * 100, 2) AS growth_percent
FROM monthly_sales
ORDER BY month DESC
LIMIT 12;

-- Customer Acquisition Rate
SELECT 
    DATE_FORMAT(first_order_date, '%Y-%m') AS month,
    COUNT(*) AS new_customers
FROM (
    SELECT 
        c.id,
        MIN(po.order_date) AS first_order_date
    FROM customers c
    JOIN purchase_orders po ON c.id = po.customer_id
    GROUP BY c.id
) AS first_orders
GROUP BY DATE_FORMAT(first_order_date, '%Y-%m')
ORDER BY month DESC;
