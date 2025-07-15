-- Database schema for Le Kiosk Inventory System

-- Products Table
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    initial_stock INTEGER NOT NULL DEFAULT 0,
    price REAL NOT NULL,
    -- Assuming a category might be useful later
    category TEXT,
    supplier TEXT,
    date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sales Table
CREATE TABLE sales (
    sale_id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    quantity_sold INTEGER NOT NULL,
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Price at the time of sale, in case product price changes
    price_at_sale REAL NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Inventory View (Virtual Stock on Hand)
-- This view will calculate the current stock for each product
CREATE VIEW inventory_stock AS
SELECT
    p.product_id,
    p.name,
    p.description,
    p.price,
    p.initial_stock,
    COALESCE(SUM(s.quantity_sold), 0) AS total_sold,
    (p.initial_stock - COALESCE(SUM(s.quantity_sold), 0)) AS stock_on_hand
FROM
    products p
LEFT JOIN
    sales s ON p.product_id = s.product_id
GROUP BY
    p.product_id, p.name, p.description, p.price, p.initial_stock;

-- Sample data for products
INSERT INTO products (name, description, initial_stock, price, category, supplier) VALUES
('Fresh Tuna Steak', 'Locally sourced yellowfin tuna', 50, 15.00, 'Seafood', 'Mauritius Fish Co.'),
('Island Breeze Salad', 'Mixed greens, palm hearts, mango, passion fruit dressing', 100, 9.50, 'Salads', 'Local Farms Ltd.'),
('Creole Chicken Curry', 'Traditional Mauritian chicken curry with rice and roti', 75, 12.75, 'Main Course', 'Island Poultry'),
('Vanilla Bean Panna Cotta', 'Dessert made with local vanilla beans', 60, 7.00, 'Desserts', 'Sweet Treats Ltd.');

-- Sample data for sales
INSERT INTO sales (product_id, quantity_sold, price_at_sale) VALUES
(1, 2, 15.00), -- Sold 2 Tuna Steaks
(2, 5, 9.50),  -- Sold 5 Island Breeze Salads
(1, 3, 15.00),  -- Sold another 3 Tuna Steaks
(3, 4, 12.75); -- Sold 4 Creole Chicken Curries

-- Users Table
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL
);

-- Insert a default user. IMPORTANT: The password is 'admin'.
-- The hash is generated using Werkzeug's generate_password_hash('admin').
-- If you change the password, you must generate a new hash.
INSERT INTO users (username, password_hash) VALUES
('admin', 'pbkdf2:sha256:600000$DmUv7g3E0kE0a2l1$8f542d4a7f28452b485303a7498c45f448e8979c3132d4a27546e5a6f2360f25');
