# Vehicle Spare Parts Management System

A Spring Boot application for managing customer orders, invoices, and payments.

## Overview

This system is a web-based vehicle spare parts management platform designed to manage customers, orders, invoices, payments, and inventory-related workflows.

- **Manage Customers**: Create, update, view, and delete customer records
- **Track Orders**: Monitor purchase orders with status tracking and delivery information
- **Handle Payments**: Process invoices and track payment status
- **Manage Inventory**: Coordinate with inventory teams for order fulfillment

## Technology Stack

- **Java 21**
- **Spring Boot 3.3.5**
- **Spring Data JPA**
- **MySQL Database**
- **Thymeleaf** (Template Engine)
- **Maven** (Build Tool)

## Database Configuration

The application uses MySQL database. 

### Quick Setup
1. See **`DATABASE_SETUP.md`** for detailed setup instructions
2. Run **`database-migration.sql`** to create tables and sample data
3. Update your password in `application.properties`:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/order_management_db
spring.datasource.username=root
spring.datasource.password=${DB_PASSWORD}

For security, the database password should be provided through the `DB_PASSWORD` environment variable instead of storing it directly in the source code.
```

### Database Files Included
- **`database-migration.sql`** - Complete database setup with sample data
- **`useful-queries.sql`** - Common queries for daily operations
- **`advanced-reports.sql`** - Analytics and reporting queries
- **`DATABASE_SETUP.md`** - Comprehensive setup guide

The database will be created automatically on first run.

## Running the Application

1. Ensure MySQL is running on your system
2. Update database credentials in `src/main/resources/application.properties`
3. Run the application:
   ```bash
   mvn spring-boot:run
   ```
4. Access the application at: `http://localhost:8080`

## Key Features

### Customer Management
- View all customers in a dashboard
- Add new customers with contact details
- Edit existing customer information
- Delete customers (with confirmation)

### Order Management
- View all purchase orders
- Filter orders by customer
- Update order status (NEW, PROCESSING, SHIPPED, DELIVERED)
- Track delivery with tracking numbers

### Payment Management
- View all invoices
- Track payment status
- Mark invoices as paid
- Link invoices to orders and customers

## Project Structure

```
src/main/java/com/example/spareparts/
├── controller/          # REST controllers
│   ├── CustomerController.java
│   ├── OrderController.java
│   ├── PaymentController.java
│   └── HomeController.java
├── model/              # Entity classes
│   ├── Customer.java
│   ├── PurchaseOrder.java
│   ├── Invoice.java
│   └── VehicleItem.java
├── repository/         # JPA repositories
│   ├── CustomerRepository.java
│   ├── OrderRepository.java
│   └── InvoiceRepository.java
├── service/           # Business logic
│   ├── CustomerService.java
│   ├── OrderService.java
│   └── InvoiceService.java
└── config/           # Configuration
    └── DataInitializer.java

src/main/resources/
├── templates/         # Thymeleaf templates
│   ├── customer-dashboard.html
│   ├── customer-form.html
│   ├── view-orders.html
│   ├── update-delivery.html
│   └── check-payment.html
└── application.properties
```

## API Endpoints

### Customer Management
- `GET /customers/dashboard` - View all customers
- `GET /customers/create` - Show customer creation form
- `POST /customers/save` - Save customer
- `GET /customers/edit/{id}` - Edit customer
- `POST /customers/delete/{id}` - Delete customer

### Order Management
- `GET /orders` - View all orders
- `GET /orders?customerId={id}` - View orders by customer
- `GET /orders/edit/{id}` - Edit order delivery status
- `POST /orders/update` - Update order

### Payment Management
- `GET /payments` - View all invoices
- `GET /payments?customerId={id}` - View invoices by customer
- `POST /payments/mark-paid` - Mark invoice as paid

## Initial Data

The application seeds one sample customer on first run:
- **Name**: John Doe
- **Email**: john.doe@example.com
- **Contact**: +1-555-0100
- **Address**: 123 Main Street, New York, NY

## Development

To enable hot reload during development:
```properties
spring.thymeleaf.cache=false
spring.devtools.restart.enabled=true
```

## License

This project is open source and available for educational purposes.
