# Quick Start Guide - Order Management System

## Prerequisites
- Java 21 or higher
- MySQL Server 8.0+
- Maven 3.6+

## Setup Steps

### 1. Configure Database
Open `src/main/resources/application.properties` and update your MySQL password:
```properties
spring.datasource.password=YOUR_MYSQL_PASSWORD
```

### 2. Build the Project
```bash
mvn clean install
```

### 3. Run the Application
```bash
mvn spring-boot:run
```

### 4. Access the Application
Open your browser and navigate to:
```
http://localhost:8080
```

You'll be automatically redirected to the Customer Dashboard.

## First Steps

### 1. View Sample Customer
The application comes with one pre-loaded customer:
- Name: John Doe
- Email: john.doe@example.com

### 2. Add a New Customer
1. Click "Create Customer" button
2. Fill in customer details
3. Click "Save"

### 3. Manage Orders
1. Click "View Orders" from the dashboard
2. View all purchase orders
3. Update delivery status and tracking numbers

### 4. Handle Payments
1. Click "Check Payments" from the dashboard
2. View all invoices
3. Mark invoices as paid

## Troubleshooting

### Database Connection Error
- Ensure MySQL is running
- Verify credentials in `application.properties`
- Check if port 3306 is available

### Port Already in Use
If port 8080 is already in use, change it in `application.properties`:
```properties
server.port=8081
```

### Build Errors
Run Maven clean:
```bash
mvn clean
mvn install
```

## Default Configuration

- **Server Port**: 8080
- **Database**: order_management_db (auto-created)
- **Context Path**: /
- **Default Page**: /customers/dashboard

## API Testing

You can test the REST endpoints using curl or Postman:

### Get All Customers
```bash
curl http://localhost:8080/customers/dashboard
```

### Get All Orders
```bash
curl http://localhost:8080/orders
```

### Get All Invoices
```bash
curl http://localhost:8080/payments
```

## Development Mode

For hot reload during development, the following is already enabled:
```properties
spring.thymeleaf.cache=false
spring.devtools.restart.enabled=true
```

Just save your changes and refresh the browser!

## Need Help?

Refer to:
- `README.md` - Full documentation
- `TRANSFORMATION_SUMMARY.md` - Complete list of changes made
