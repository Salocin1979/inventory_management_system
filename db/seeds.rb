# Destroy records in the correct order to avoid foreign key issues
StockTransaction.destroy_all
Item.destroy_all
Supplier.destroy_all
Category.destroy_all
Warehouse.destroy_all
User.destroy_all

# Create admin user
admin = User.create!(
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123'
)

# Create categories
electronics = Category.create!(name: 'Electronics', description: 'Electronic devices and components')
office_supplies = Category.create!(name: 'Office Supplies', description: 'Stationery and office equipment')
furniture = Category.create!(name: 'Furniture', description: 'Office furniture and fixtures')

# Create warehouses
main_warehouse = Warehouse.create!(name: 'Main Warehouse', location: '123 Main St, City', manager_name: 'John Smith', contact_email: 'john@example.com', contact_phone: '555-1234')
east_warehouse = Warehouse.create!(name: 'East Facility', location: '456 East Ave, City', manager_name: 'Jane Doe', contact_email: 'jane@example.com', contact_phone: '555-5678')

# Ensure suppliers exist before using them
# To this:
supplier1 = Supplier.create!(name: 'Supplier 1', email: 'supplier1@example.com', phone: '123-456-7890', contact_person: 'Alex Johnson')
supplier2 = Supplier.create!(name: 'Supplier 2', email: 'supplier2@example.com', phone: '987-654-3210', contact_person: 'Maria Garcia')

# Now create items, referencing the suppliers
items = [
  { name: 'Laptop', description: 'Business laptop, 15-inch display', sku: 'EL-001', barcode: '1000000001', category: electronics, warehouse: main_warehouse, supplier: supplier1, current_stock: 15, minimum_stock: 5, reorder_point: 10, unit_cost: 799.99 },
  { name: 'Desk Chair', description: 'Ergonomic office chair with armrests', sku: 'FN-001', barcode: '1000000002', category: furniture, warehouse: main_warehouse, supplier: supplier2, current_stock: 8, minimum_stock: 3, reorder_point: 5, unit_cost: 149.99 },
  { name: 'Printer Paper', description: 'A4 size, 500 sheets per ream', sku: 'OS-001', barcode: '1000000003', category: office_supplies, warehouse: east_warehouse, supplier: supplier2, current_stock: 50, minimum_stock: 10, reorder_point: 20, unit_cost: 4.99 }
]

items.each do |item|
  Item.create!(item)
end
