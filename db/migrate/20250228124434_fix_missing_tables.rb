class FixMissingTables < ActiveRecord::Migration[8.0]
  def change
    # Create storage_locations table
    create_table :storage_locations do |t|
      t.string :name
      t.text :description
      t.references :cost_center, foreign_key: true
      t.timestamps
    end

    # Create vendors table (might be the same as suppliers in your case)
    create_table :vendors do |t|
      t.string :name
      t.string :contact_person
      t.string :email
      t.string :phone
      t.text :address
      t.timestamps
    end

    # Create base_units table
    create_table :base_units do |t|
      t.string :name
      t.string :abbreviation
      t.timestamps
    end

    # Remove problematic foreign keys
    remove_foreign_key :orders, :approved_bies, if_exists: true
    remove_foreign_key :orders, :created_bies, if_exists: true
    remove_foreign_key :receipts, :received_bies, if_exists: true

    # Make these columns reference users instead
    change_column :orders, :approved_by_id, :integer, null: true
    change_column :orders, :created_by_id, :integer, null: true
    change_column :receipts, :received_by_id, :integer, null: true

    # Add correct foreign keys
    add_foreign_key :orders, :users, column: :approved_by_id, if_exists: true
    add_foreign_key :orders, :users, column: :created_by_id, if_exists: true
    add_foreign_key :receipts, :users, column: :received_by_id, if_exists: true
  end
end
