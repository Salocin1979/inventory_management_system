class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.string :order_number
      t.references :vendor, null: false, foreign_key: true
      t.references :cost_center, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: true
      t.references :approved_by, null: false, foreign_key: true
      t.datetime :order_date
      t.datetime :expected_delivery_date
      t.string :status
      t.text :notes
      t.decimal :total_amount
      t.references :order_cycle, null: false, foreign_key: true

      t.timestamps
    end
  end
end
