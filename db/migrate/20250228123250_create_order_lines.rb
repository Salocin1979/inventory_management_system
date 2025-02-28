class CreateOrderLines < ActiveRecord::Migration[8.0]
  def change
    create_table :order_lines do |t|
      t.references :order, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.decimal :quantity
      t.decimal :price
      t.references :unit_of_measure, null: false, foreign_key: true
      t.decimal :total
      t.string :status

      t.timestamps
    end
  end
end
