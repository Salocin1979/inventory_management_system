class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.string :name
      t.text :description
      t.string :sku
      t.string :barcode
      t.references :category, null: false, foreign_key: true
      t.references :warehouse, null: false, foreign_key: true
      t.integer :current_stock
      t.integer :minimum_stock
      t.integer :reorder_point
      t.decimal :unit_cost

      t.timestamps
    end
  end
end
