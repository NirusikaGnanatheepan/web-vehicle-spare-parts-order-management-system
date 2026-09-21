# Database Schema Documentation

## Entity Relationship Diagram (Text Format)

```
┌─────────────────────────────────────────────────────────────────┐
│                    ORDER MANAGEMENT SYSTEM                       │
│                        Database Schema                           │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────────┐
│     CUSTOMERS        │
├──────────────────────┤
│ PK  id              │◄───────┐
│     name            │        │
│     email           │        │ One-to-Many
│     contact_number  │        │
│     address         │        │
│     created_at      │        │
│     updated_at      │        │
└──────────────────────┘        │
                                │
                    ┌───────────┴───────────┐
                    │                       │
                    │                       │
        ┌───────────▼──────────┐   ┌───────▼──────────┐
        │  PURCHASE_ORDERS     │   │    INVOICES      │
        ├──────────────────────┤   ├──────────────────┤
        │ PK  id              │◄──┐│ PK  id          │
        │     order_date      │   ││     amount      │
        │     status          │   ││     payment_st. │
        │     tracking_number │   ││     payment_dt. │
        │     total_amount    │   │├─────────────────┤
        ├─────────────────────┤   ││ FK  customer_id │
        │ FK  customer_id     │   ││ FK  order_id    │
        │     created_at      │   │└─────────────────┘
        │     updated_at      │   │
        └─────────────────────┘   │
                │                 │
                │ One-to-Many     │ One-to-One
                │                 │
        ┌───────▼──────────┐      │
        │  VEHICLE_ITEMS   │      │
        ├──────────────────┤      │
        │ PK  id          │      │
        │     item_name   │      │
        │     quantity    │      │
        │     unit_price  │      │
        ├─────────────────┤      │
        │ FK  order_id    ├──────┘
        │     created_at  │
        └─────────────────┘
```

## Table Relationships

### 1. CUSTOMERS → PURCHASE_ORDERS
- **Type**: One-to-Many
- **Foreign Key**: `purchase_orders.customer_id` → `customers.id`
- **Cascade**: ON DELETE CASCADE
- **Description**: One customer can have multiple orders

### 2. CUSTOMERS → INVOICES
- **Type**: One-to-Many
- **Foreign Key**: `invoices.customer_id` → `customers.id`
- **Cascade**: ON DELETE CASCADE
- **Description**: One customer can have multiple invoices

### 3. PURCHASE_ORDERS → VEHICLE_ITEMS
- **Type**: One-to-Many
- **Foreign Key**: `vehicle_items.order_id` → `purchase_orders.id`
- **Cascade**: ON DELETE CASCADE
- **Description**: One order can contain multiple items

### 4. PURCHASE_ORDERS → INVOICES
- **Type**: One-to-One
- **Foreign Key**: `invoices.order_id` → `purchase_orders.id`
- **Cascade**: ON DELETE SET NULL
- **Description**: One order typically has one invoice

## Detailed Table Schemas

### CUSTOMERS Table
```sql
CREATE TABLE customers (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(255)    NOT NULL,
    email           VARCHAR(255),
    contact_number  VARCHAR(50),
    address         VARCHAR(500),
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

**Indexes**:
- PRIMARY KEY on `id`

**Constraints**:
- `name` is NOT NULL

**Sample Data**:
```
id | name        | email                  | contact_number | address
---|-------------|------------------------|----------------|---------------------------
1  | John Doe    | john.doe@example.com   | +1-555-0100   | 123 Main St, New York, NY
2  | Jane Smith  | jane.smith@example.com | +1-555-0101   | 456 Oak Ave, LA, CA
```

---

### PURCHASE_ORDERS Table
```sql
CREATE TABLE purchase_orders (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    order_date      DATE            NOT NULL,
    status          VARCHAR(50)     DEFAULT 'NEW',
    tracking_number VARCHAR(100),
    total_amount    DOUBLE,
    customer_id     BIGINT          NOT NULL,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);
```

**Indexes**:
- PRIMARY KEY on `id`
- INDEX on `customer_id`
- INDEX on `status`
- INDEX on `order_date`

**Constraints**:
- `order_date` is NOT NULL
- `customer_id` is NOT NULL
- Foreign key to `customers.id`

**Status Values**:
- `NEW` - Order just created
- `PROCESSING` - Order being prepared
- `SHIPPED` - Order shipped to customer
- `DELIVERED` - Order delivered

**Sample Data**:
```
id | order_date  | status     | tracking_number | total_amount | customer_id
---|-------------|------------|-----------------|--------------|------------
1  | 2025-10-05  | NEW        | NULL           | 1500.00      | 1
2  | 2025-09-30  | PROCESSING | TRK123456      | 2300.00      | 2
3  | 2025-09-25  | SHIPPED    | TRK789012      | 890.00       | 1
4  | 2025-09-20  | DELIVERED  | TRK345678      | 3200.00      | 3
```

---

### INVOICES Table
```sql
CREATE TABLE invoices (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    amount          DOUBLE          NOT NULL,
    payment_status  VARCHAR(50)     DEFAULT 'PENDING',
    payment_date    DATE,
    customer_id     BIGINT          NOT NULL,
    order_id        BIGINT,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES purchase_orders(id) ON DELETE SET NULL
);
```

**Indexes**:
- PRIMARY KEY on `id`
- INDEX on `customer_id`
- INDEX on `payment_status`

**Constraints**:
- `amount` is NOT NULL
- `customer_id` is NOT NULL
- Foreign key to `customers.id`
- Foreign key to `purchase_orders.id`

**Payment Status Values**:
- `PENDING` - Payment not yet received
- `PAID` - Payment received and confirmed

**Sample Data**:
```
id | amount   | payment_status | payment_date | customer_id | order_id
---|----------|----------------|--------------|-------------|----------
1  | 1500.00  | PENDING       | NULL         | 1           | 1
2  | 2300.00  | PAID          | 2025-10-02   | 2           | 2
3  | 890.00   | PAID          | 2025-09-27   | 1           | 3
4  | 3200.00  | PAID          | 2025-09-23   | 3           | 4
```

---

### VEHICLE_ITEMS Table
```sql
CREATE TABLE vehicle_items (
    id              BIGINT          AUTO_INCREMENT PRIMARY KEY,
    item_name       VARCHAR(255)    NOT NULL,
    quantity        INT             DEFAULT 1,
    unit_price      DOUBLE,
    order_id        BIGINT,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES purchase_orders(id) ON DELETE CASCADE
);
```

**Indexes**:
- PRIMARY KEY on `id`
- INDEX on `order_id`

**Constraints**:
- `item_name` is NOT NULL
- Foreign key to `purchase_orders.id`

**Sample Data**:
```
id | item_name          | quantity | unit_price | order_id
---|--------------------|----------|------------|----------
1  | Brake Pads         | 4        | 75.00      | 1
2  | Oil Filter         | 2        | 25.00      | 1
3  | Air Filter         | 1        | 45.00      | 2
4  | Spark Plugs        | 8        | 15.00      | 2
5  | Windshield Wipers  | 2        | 30.00      | 3
6  | Battery            | 1        | 150.00     | 4
```

## Data Flow

### Order Creation Flow
```
1. Create Customer
   ↓
2. Create Purchase Order (with customer_id)
   ↓
3. Add Vehicle Items (with order_id)
   ↓
4. Create Invoice (with customer_id and order_id)
   ↓
5. Process Payment (update invoice status)
```

### Deletion Cascade
```
Delete Customer
   ↓ CASCADE
Delete All Purchase Orders for that customer
   ↓ CASCADE
Delete All Vehicle Items for those orders
   ↓ CASCADE
Delete All Invoices for that customer
```

## Indexes Summary

| Table            | Index Name           | Column(s)      | Type    |
|------------------|---------------------|----------------|---------|
| customers        | PRIMARY             | id             | PRIMARY |
| purchase_orders  | PRIMARY             | id             | PRIMARY |
| purchase_orders  | idx_customer_id     | customer_id    | INDEX   |
| purchase_orders  | idx_status          | status         | INDEX   |
| purchase_orders  | idx_order_date      | order_date     | INDEX   |
| invoices         | PRIMARY             | id             | PRIMARY |
| invoices         | idx_customer_id     | customer_id    | INDEX   |
| invoices         | idx_payment_status  | payment_status | INDEX   |
| vehicle_items    | PRIMARY             | id             | PRIMARY |
| vehicle_items    | idx_order_id        | order_id       | INDEX   |

## Common Queries

### Get Customer with All Orders
```sql
SELECT c.*, po.*
FROM customers c
LEFT JOIN purchase_orders po ON c.id = po.customer_id
WHERE c.id = ?;
```

### Get Order with All Items
```sql
SELECT po.*, vi.*
FROM purchase_orders po
LEFT JOIN vehicle_items vi ON po.id = vi.order_id
WHERE po.id = ?;
```

### Get Customer Outstanding Balance
```sql
SELECT c.name, SUM(i.amount) AS outstanding
FROM customers c
JOIN invoices i ON c.id = i.customer_id
WHERE i.payment_status = 'PENDING'
GROUP BY c.id, c.name;
```

## Database Size Estimates

Based on typical usage:

| Table            | Rows/Year | Storage/Row | Total/Year |
|------------------|-----------|-------------|------------|
| customers        | 1,000     | ~500 bytes  | ~500 KB    |
| purchase_orders  | 10,000    | ~200 bytes  | ~2 MB      |
| vehicle_items    | 30,000    | ~150 bytes  | ~4.5 MB    |
| invoices         | 10,000    | ~150 bytes  | ~1.5 MB    |
| **Total**        |           |             | **~8.5 MB**|

## Backup Recommendations

- **Daily**: Incremental backup of all tables
- **Weekly**: Full database backup
- **Monthly**: Archive old completed orders (>1 year)
- **Retention**: Keep backups for 90 days minimum

## Performance Tips

1. **Indexes**: Already optimized with indexes on foreign keys and frequently queried columns
2. **Partitioning**: Consider partitioning `purchase_orders` by `order_date` if data grows large
3. **Archiving**: Move old delivered orders to archive table after 1 year
4. **Query Optimization**: Use EXPLAIN to analyze slow queries
5. **Connection Pooling**: Configure HikariCP in Spring Boot for optimal connections
