# Smart Retail Grocery & Perishable Food Inventory Management System 📦🍎🥛

A modern, fast, and feature-rich Java-based enterprise Web Application designed specifically for the **FMCG, Retail Grocery, and Perishable Food Logistics** industry. Featuring a **fully responsive layout**, it adapts seamlessly across desktop, laptop, tablet, and mobile phone screens.

Built using Java EE (Servlets & JSP), Bootstrap 5 for clean UX/UI, and MySQL, the application features an embedded HikariCP connection pool for low-latency queries and runs on any Java Web container (Tomcat / Jetty / Docker).

---

## 🏬 Industry-Specific Features

Unlike general-purpose stock managers, this system is optimized for **grocery retail and perishable foods management**:
- **Perishable Lifecycle Management**: Tracks items with explicit `expiry_date` attributes.
- **Multi-Category Food Catalog**: Pre-categorized for *Fresh Produce, Dairy & Eggs, Meat & Seafood, Bakery & Bread, Beverages, Snacks & Confectionery, Frozen Foods, Grains & Pulses*.
- **Automated Expiry Forecasting**: Calculates shelf-life margins and flags products nearing expiry or already expired.
- **Stock Threshold Safety Bounds**: Restricts stock-out (sales) operations if they exceed current physical capacity or database levels.

---

## 🚀 Key Features

- **Responsive Mobile-First UI**: Seamless user experience optimized for both large screens (laptops, monitors) and touch-first devices (mobile phones, tablets) using collapsible sidebars and fluid grids.
- **Interactive Analytics Dashboard**: Real-time category distribution charts, KPIs (total items, low stock, expired, near-expiry), and recent audit trails.
- **Product Catalog Management**: Dynamic searching, category filters, supplier assignments, and minimum threshold configurations.
- **Optimized Stock Moves (In/Out)**: Full transaction logging with automatic inventory level updates, safety check bounds, and auto-complete product searches.
- **Smart Notification System**: Automated background alerts identifying low-stock levels and near-expiry/expired items with mock email/SMS triggers.
- **Interactive Reports Desk**: Instantly generate & download inventory reports in **CSV** or print-ready **PDF** formats.
- **Secure Authentication**: Role-based access control (Admin vs. Manager) with session validations.

---

## 🛠️ Tech Stack

- **Core Engine**: Java 8+ / Java Servlet API & JSP
- **Database**: MySQL 8.0+
- **Connection Pool**: HikariCP (Fast connection pooling for low-latency queries)
- **Reporting Engine**: iText PDF Library
- **Analytics Visualization**: Chart.js
- **Design & UI**: Bootstrap 5 (responsive custom dark-blue theme)
- **Build System**: Apache Maven 3.9+

---

## 🎯 Demo Mode Walkthrough

To try the application instantly without manual registration:

1. **One-Click Demo Sign In**:
   * Navigate to the login page and click the primary **Demo** button.
   * This automatically authenticates you as a demo user and logs you into the dashboard populated with default grocery suppliers (like *FreshFarms Co*, *Apex Dairy Ltd*) and a catalog of 35+ grocery items.

2. **Automated Alerting Simulation**:
   * The application starts a background task (`AlertScheduler`) that runs on startup and rescans the inventory.
   * Check your application logs/console to view simulated JavaMail and SMS gateway triggers for items like *Butter Croissants (4pk)* (Expired) or *Whole Milk (1L)* (Low Stock).

3. **Billing Desk / Cart System**:
   * Go to the **Stock Sales** tab.
   * Search for products (e.g., "Whole Milk" or "Organic Apples") using the autocomplete search bar.
   * Adjust quantities and click **Add to Cart**.
   * Click **Complete Sale & Generate Bill** to process the stock-out and instantly view the generated PDF invoice.

---

## 🗄️ Database Schema

The database is built on 5 relational tables:
1. `users` (Authentication & roles: `ADMIN`, `MANAGER`, `DEMO`)
2. `suppliers` (Contact records & physical address registry)
3. `products` (SKU identifiers, thresholds, and expiry logs)
4. `transactions` (Stock movement ledger: `STOCK_IN`, `STOCK_OUT`)
5. `alerts` (Automatic flags: `LOW_STOCK`, `NEAR_EXPIRY`, `EXPIRED`)

---

## 💻 Local Setup & Quickstart

### Prerequisites
- **JDK 1.8** or newer installed.
- **MySQL Server** running locally or externally.

### 1. Database Configuration
Update the [db.properties](file:///src/main/resources/db.properties) file under `src/main/resources` with your MySQL database details:
```properties
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://<db-host>:<port>/<db-name>?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
db.username=<your-username>
db.password=<your-password>
```

### 2. Database Schema Initialization
Import the database setup file into your MySQL database instance:
- Run [schema.sql](file:///schema.sql) (or [init_database.sql](file:///init_database.sql) which contains complete pre-configured seed data).

### 3. Launching Locally
Double-click the custom startup script [run_smartinventory.bat](file:///run_smartinventory.bat) or run the command below:
```cmd
mvn clean package -DskipTests
mvn jetty:run
```
Once started, open [http://localhost:8081/smart_inventory/](http://localhost:8081/smart_inventory/) in your browser.

---

## ☁️ Production Deployment (Render / Docker)

The app includes a [Dockerfile](file:///Dockerfile) and [render.yaml](file:///render.yaml) configuration for instant deployment to Render.

### Environment Variables
Configure the following variables in your Render web service panel:
* `DB_URL`: The remote JDBC connection string.
* `DB_USERNAME`: The remote MySQL user.
* `DB_PASSWORD`: The remote MySQL password.

---

## 🔑 Default Access Credentials

| Role | Username | Password |
| :--- | :--- | :--- |
| **Administrator** | `admin` | `admin123` |
| **Manager** | `manager` | `manager123` |
| **Demo User** | `demo` | `demo123` |
