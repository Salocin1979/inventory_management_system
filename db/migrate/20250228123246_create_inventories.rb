class CreateInventories < ActiveRecord::Migration[8.0]
  def change
    create_table :inventories do |t|
      t.references :item, null: false, foreign_key: true
      t.references :cost_center, null: false, foreign_key: true
      t.references :storage_location, null: false, foreign_key: true
      t.decimal :quantity

      t.timestamps
    end
  end
end
