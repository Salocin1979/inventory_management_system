import sqlite3
from flask import Flask, render_template, request, redirect, url_for, g

DATABASE = 'inventory.db'

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your_secret_key' # Important for session management, flash messages

def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = sqlite3.connect(DATABASE)
        db.row_factory = sqlite3.Row # Access columns by name
    return db

@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()

def init_db():
    with app.app_context():
        db = get_db()
        with app.open_resource('database_schema.sql', mode='r') as f:
            db.cursor().executescript(f.read())
        db.commit()

# --- Product Functions ---
def add_product_to_db(name, description, initial_stock, price, category=None, supplier=None):
    db = get_db()
    cursor = db.cursor()
    cursor.execute("""
        INSERT INTO products (name, description, initial_stock, price, category, supplier)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (name, description, initial_stock, price, category, supplier))
    db.commit()
    return cursor.lastrowid

def get_all_products():
    db = get_db()
    cursor = db.cursor()
    cursor.execute("SELECT * FROM products ORDER BY name")
    products = cursor.fetchall()
    return products

def get_product_by_id(product_id):
    db = get_db()
    cursor = db.cursor()
    cursor.execute("SELECT * FROM products WHERE product_id = ?", (product_id,))
    product = cursor.fetchone()
    return product

# --- Sales Functions ---
def add_sale_to_db(product_id, quantity_sold, price_at_sale):
    db = get_db()
    cursor = db.cursor()
    cursor.execute("""
        INSERT INTO sales (product_id, quantity_sold, price_at_sale)
        VALUES (?, ?, ?)
    """, (product_id, quantity_sold, price_at_sale))
    db.commit()
    return cursor.lastrowid

def get_all_sales():
    db = get_db()
    cursor = db.cursor()
    cursor.execute("""
        SELECT s.sale_id, p.name AS product_name, s.quantity_sold, s.price_at_sale, s.sale_date
        FROM sales s
        JOIN products p ON s.product_id = p.product_id
        ORDER BY s.sale_date DESC
    """)
    sales = cursor.fetchall()
    return sales

# --- Inventory Functions ---
def get_inventory_stock():
    db = get_db()
    cursor = db.cursor()
    # Using the view created in database_schema.sql
    cursor.execute("SELECT * FROM inventory_stock ORDER BY name")
    inventory = cursor.fetchall()
    return inventory

# --- Routes (Basic examples, will be expanded) ---
@app.route('/')
def home():
    # This will eventually be the Le Kiosk homepage
    return render_template('homepage.html')

@app.route('/dashboard_overview') # Renamed to avoid conflict with actual dashboard later
def dashboard():
    products = get_all_products()
    sales = get_all_sales()
    inventory = get_inventory_stock()
    return render_template('dashboard_overview.html', products=products, sales=sales, inventory=inventory)

@app.route('/add_product_form', methods=['GET', 'POST'])
def add_product_form():
    if request.method == 'POST':
        name = request.form['name']
        description = request.form['description']
        initial_stock = int(request.form['initial_stock'])
        price = float(request.form['price'])
        category = request.form.get('category') # Optional
        supplier = request.form.get('supplier') # Optional
        add_product_to_db(name, description, initial_stock, price, category, supplier)
        return redirect(url_for('dashboard'))
    return render_template('add_product.html') # A simple form

@app.route('/add_sale_form', methods=['GET', 'POST'])
def add_sale_form():
    products = get_all_products() # For dropdown in form
    if request.method == 'POST':
        product_id = int(request.form['product_id'])
        quantity_sold = int(request.form['quantity_sold'])

        product = get_product_by_id(product_id)
        if not product:
            # Handle error: product not found
            return "Error: Product not found", 404

        price_at_sale = product['price'] # Use current product price

        # Basic check for stock (can be more sophisticated)
        inventory_item = next((item for item in get_inventory_stock() if item['product_id'] == product_id), None)
        if inventory_item and inventory_item['stock_on_hand'] < quantity_sold:
            error_message = f"Insufficient stock for {product['name']}. Available: {inventory_item['stock_on_hand']}"
            return render_template('add_sale.html', products=products, error=error_message)

        add_sale_to_db(product_id, quantity_sold, price_at_sale)
        return redirect(url_for('dashboard'))
    return render_template('add_sale.html', products=products)


if __name__ == '__main__':
    init_db() # Initialize the database and create tables if they don't exist
    app.run(debug=True)
