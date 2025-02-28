class CreateMissingTables < ActiveRecord::Migration[8.0]
  def change
    # Only create if it doesn't exist
    unless table_exists?(:storage_locations)
      create_table :storage_locations do |t|
        t.string :name
        t.text :description
        t.references :cost_center, foreign_key: true
        t.timestamps
      end
    end

    # Create vendors table if it doesn't exist
    unless table_exists?(:vendors)
      create_table :vendors do |t|
        t.string :name
        t.string :contact_person
        t.string :email
        t.string :phone
        t.text :address
        t.timestamps
      end
    end

    # Create base_units table if it doesn't exist
    unless table_exists?(:base_units)
      create_table :base_units do |t|
        t.string :name
        t.string :abbreviation
        t.timestamps
      end
    end

    # Update existing foreign key columns
    change_column :orders, :approved_by_id, :integer, null: true if column_exists?(:orders, :approved_by_id)
    change_column :orders, :created_by_id, :integer, null: true if column_exists?(:orders, :created_by_id)
    change_column :receipts, :received_by_id, :integer, null: true if column_exists?(:receipts, :received_by_id)
  end
end
