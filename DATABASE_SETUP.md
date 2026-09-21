# Database Setup Guide

## Prerequisites
- MySQL Server 8.0 or higher installed
- MySQL client or MySQL Workbench
- Database user with CREATE, INSERT, UPDATE, DELETE privileges

## Setup Options

### Option 1: Fresh Installation (Recommended)

This is the easiest option if you're starting fresh or don't have existing data.

#### Step 1: Login to MySQL
```bash
mysql -u root -p
```

#### Step 2: Run the Migration Script
```sql
source /path/to/database-migration.sql
```

Or copy and paste the contents of `database-migration.sql` into your MySQL client.

#### Step 3: Verify Installation
```sql
USE order_management_db;
SHOW TABLES;
SELECT * FROM customers;
```

You should see 4 tables:
- `customers`
- `purchase_orders`
- `invoices`
- `vehicle_items`

### Option 2: Migrate from Existing Supplier Database

If you have existing data in `supplier_db`, use this option.

#### Step 1: Backup Existing Database
```bash
mysqldump -u root -p supplier_db > supplier_db_backup.sql
```

#### Step 2: Run Migration Commands
```sql
USE supplier_db;

-- Rename table
RENAME TABLE suppliers TO customers;

-- Update foreign key columns
ALTER TABLE purchase_orders CHANGE COLUMN supplier_id customer_id BIGINT NOT NULL;
ALTER TABLE invoices CHANGE COLUMN supplier_id customer_id BIGINT NOT NULL;

-- Drop old foreign key constraints
ALTER TABLE purchase_orders DROP FOREIGN KEY purchase_orders_ibfk_1;
ALTER TABLE invoices DROP FOREIGN KEY invoices_ibfk_1;

-- Add new foreign key constraints
ALTER TABLE purchase_orders 
    ADD CONSTRAINT fk_purchase_orders_customer 
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE;

ALTER TABLE invoices 
    ADD CONSTRAINT fk_invoices_customer 
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE;

-- Add indexes for performance
CREATE INDEX idx_customer_id ON purchase_orders(customer_id);
CREATE INDEX idx_customer_id ON invoices(customer_id);
CREATE INDEX idx_status ON purchase_orders(status);
CREATE INDEX idx_payment_status ON invoices(payment_status);
```

#### Step 3: Update Application Configuration
Keep using `supplier_db` or rename it:
```properties
# In application.properties
spring.datasource.url=jdbc:mysql://localhost:3306/supplier_db
```

Or rename the database:
```sql
-- Create new database
CREATE DATABASE order_management_db;

-- Copy all tables
CREATE TABLE order_management_db.customers AS SELECT * FROM supplier_db.customers;
CREATE TABLE order_management_db.purchase_orders AS SELECT * FROM supplier_db.purchase_orders;
CREATE TABLE order_management_db.invoices AS SELECT * FROM supplier_db.invoices;
CREATE TABLE order_management_db.vehicle_items AS SELECT * FROM supplier_db.vehicle_items;
```

## Database Schema

### Customers Table
```sql
CREATE TABLE customers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    contact_number VARCHAR(50),
    address VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Purchase Orders Table
```sql
CREATE TABLE purchase_orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'NEW',
    tracking_number VARCHAR(100),
    total_amount DOUBLE,
    customer_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);
```

### Invoices Table
```sql
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
    FOREIGN KEY (order_id) REFERENCES purchase_orders(id) ON DELETE SET NULL
);
```

### Vehicle Items Table
```sql
CREATE TABLE vehicle_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(255) NOT NULL,
    quantity INT DEFAULT 1,
    unit_price DOUBLE,
    order_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES purchase_orders(id) ON DELETE CASCADE
);
```

## Sample Data

The migration script includes sample data:
- 3 customers
- 4 orders with different statuses
- 6 vehicle items
- 4 invoices (3 paid, 1 pending)

## Verification Queries

After setup, verify everything is working:

```sql
-- Check all tables exist
SHOW TABLES;

-- Count records
SELECT 
    (SELECT COUNT(*) FROM customers) AS customers,
    (SELECT COUNT(*) FROM purchase_orders) AS orders,
    (SELECT COUNT(*) FROM invoices) AS invoices,
    (SELECT COUNT(*) FROM vehicle_items) AS items;

-- View sample data
SELECT * FROM customers;
SELECT * FROM purchase_orders;
SELECT * FROM invoices;
SELECT * FROM vehicle_items;
```

## Useful Queries

See `useful-queries.sql` for a comprehensive collection of queries including:
- Customer analytics
- Order reports
- Payment tracking
- Revenue analysis
- Maintenance operations

## Common Issues

### Issue: Access Denied
**Solution**: Grant proper privileges
```sql
GRANT ALL PRIVILEGES ON order_management_db.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
```

### Issue: Foreign Key Constraint Fails
**Solution**: Ensure parent records exist before inserting child records
```sql
-- Always insert customers first
INSERT INTO customers (...) VALUES (...);

-- Then orders
INSERT INTO purchase_orders (customer_id, ...) VALUES (1, ...);

-- Then items and invoices
INSERT INTO vehicle_items (order_id, ...) VALUES (1, ...);
```

### Issue: Database Already Exists
**Solution**: Drop and recreate
```sql
DROP DATABASE IF EXISTS order_management_db;
CREATE DATABASE order_management_db;
```

## Performance Optimization

### Add Indexes
```sql
-- Already included in migration script
CREATE INDEX idx_customer_id ON purchase_orders(customer_id);
CREATE INDEX idx_status ON purchase_orders(status);
CREATE INDEX idx_payment_status ON invoices(payment_status);
CREATE INDEX idx_order_date ON purchase_orders(order_date);
```

### Analyze Tables
```sql
ANALYZE TABLE customers;
ANALYZE TABLE purchase_orders;
ANALYZE TABLE invoices;
ANALYZE TABLE vehicle_items;
```

## Backup and Restore

### Create Backup
```bash
mysqldump -u root -p order_management_db > backup_$(date +%Y%m%d).sql
```

### Restore from Backup
```bash
mysql -u root -p order_management_db < backup_20251005.sql
```

## Connection String

Update your `application.properties`:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/order_management_db?useSSL=false&allowPublicKeyRetrieval=true&createDatabaseIfNotExist=true
spring.datasource.username=root
spring.datasource.password=YOUR_PASSWORD
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect
```

## Next Steps

1. ✅ Complete database setup
2. ✅ Update `application.properties` with your MySQL password
3. ✅ Run the Spring Boot application
4. ✅ Access at `http://localhost:8080`
5. ✅ Test CRUD operations

## Support

For issues or questions:
- Check `TRANSFORMATION_SUMMARY.md` for detailed changes
- Review `useful-queries.sql` for query examples
- Refer to `README.md` for application documentation
