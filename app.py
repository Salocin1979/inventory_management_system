import sqlite3
from flask import Flask, render_template, request, redirect, url_for, g, flash
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user

DATABASE = 'inventory.db'

app = Flask(__name__)
# IMPORTANT: A secret key is required for session management and flash messages.
# In a real production app, use a long, random, and secret string.
app.config['SECRET_KEY'] = 'a-very-secret-key-that-you-should-change'

# --- Flask-Login Setup ---
login_manager = LoginManager()
login_manager.init_app(app)
# If a user tries to access a protected page, redirect them to the login page.
login_manager.login_view = 'login'
# Customize the message flashed when a user is redirected.
login_manager.login_message = "Veuillez vous connecter pour accéder à cette page."
login_manager.login_message_category = "info" # Bootstrap class for styling

class User(UserMixin):
    """User model for Flask-Login."""
    def __init__(self, id, username):
        self.id = id
        self.username = username

@login_manager.user_loader
def load_user(user_id):
    """Load user from the database."""
    db = get_db()
    user_data = db.execute("SELECT * FROM users WHERE id = ?", (user_id,)).fetchone()
    if user_data:
        return User(id=user_data['id'], username=user_data['username'])
    return None

# --- Database Functions ---
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

# --- Routes ---
@app.route('/')
def home():
    """The Le Kiosk homepage."""
    return render_template('homepage.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    """Handles user login."""
    # If the user is already logged in, redirect them to the dashboard.
    if current_user.is_authenticated:
        return redirect(url_for('dashboard'))

    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        db = get_db()
        user_data = db.execute("SELECT * FROM users WHERE username = ?", (username,)).fetchone()

        if user_data and check_password_hash(user_data['password_hash'], password):
            user = User(id=user_data['id'], username=user_data['username'])
            login_user(user)
            flash('Connexion réussie !', 'success')
            # Redirect to the page the user was trying to access, or dashboard if none.
            next_page = request.args.get('next')
            return redirect(next_page or url_for('dashboard'))
        else:
            flash('Nom d\'utilisateur ou mot de passe incorrect.', 'danger')

    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    """Handles user logout."""
    logout_user()
    flash('Vous avez été déconnecté.', 'success')
    return redirect(url_for('login'))

@app.route('/dashboard')
@login_required
def dashboard():
    """The main admin dashboard."""
    products = get_all_products()
    sales = get_all_sales()
    inventory = get_inventory_stock()

    # This is a simplified calculation for the metric card.
    # It assumes the price of the first product is representative, which is not accurate.
    # A better approach would be to calculate value per item: sum(item['stock_on_hand'] * item['price'])
    total_stock_value = 0
    if inventory:
        total_stock_value = sum(item['stock_on_hand'] * item['price'] for item in inventory)

    return render_template('dashboard_overview.html',
                           products=products,
                           sales=sales,
                           inventory=inventory,
                           total_stock_value=total_stock_value)

@app.route('/add_product', methods=['GET', 'POST'])
@login_required
def add_product_form():
    if request.method == 'POST':
        name = request.form['name']
        description = request.form['description']
        initial_stock = int(request.form['initial_stock'])
        price = float(request.form['price'])
        category = request.form.get('category')
        supplier = request.form.get('supplier')
        add_product_to_db(name, description, initial_stock, price, category, supplier)
        flash(f"Produit '{name}' ajouté avec succès.", 'success')
        return redirect(url_for('dashboard'))
    return render_template('add_product.html')

@app.route('/add_sale', methods=['GET', 'POST'])
@login_required
def add_sale_form():
    products = get_all_products()
    if request.method == 'POST':
        product_id = int(request.form['product_id'])
        quantity_sold = int(request.form['quantity_sold'])

        product = get_product_by_id(product_id)
        if not product:
            flash("Erreur : Produit non trouvé.", 'danger')
            return redirect(url_for('add_sale_form'))

        price_at_sale = product['price']

        # Check for sufficient stock
        inventory_item = next((item for item in get_inventory_stock() if item['product_id'] == product_id), None)
        if not inventory_item or inventory_item['stock_on_hand'] < quantity_sold:
            available_stock = inventory_item['stock_on_hand'] if inventory_item else 0
            error_message = f"Stock insuffisant pour {product['name']}. Disponible : {available_stock}"
            flash(error_message, 'danger')
            return render_template('add_sale.html', products=products, error=error_message)

        add_sale_to_db(product_id, quantity_sold, price_at_sale)
        flash(f"{quantity_sold} unité(s) de '{product['name']}' vendue(s).", 'success')
        return redirect(url_for('dashboard'))
    return render_template('add_sale.html', products=products)


if __name__ == '__main__':
    # It's good practice to have a command to initialize the DB separately.
    # You can create a command like `flask init-db` for that.
    # For this project, we'll assume the user deletes inventory.db to re-initialize.
    # Let's check if the user table exists to see if we need to init.
    try:
        with sqlite3.connect(DATABASE) as conn:
            # This will fail if the table doesn't exist
            conn.execute("SELECT 1 FROM users LIMIT 1").fetchone()
    except sqlite3.OperationalError:
        print("Database not initialized or 'users' table missing. Initializing database...")
        init_db()
        print("Database initialized successfully.")

    app.run(debug=True)
