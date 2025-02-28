class CreateCostCenters < ActiveRecord::Migration[8.0]
  def change
    create_table :cost_centers do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.text :description
      t.string :location
      t.boolean :active, default: true
      t.references :parent_cost_center, foreign_key: { to_table: :cost_centers }

      t.timestamps
    end

    add_index :cost_centers, :code, unique: true
  end
end
