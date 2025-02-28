class CreateOrderCycles < ActiveRecord::Migration[8.0]
  def change
    create_table :order_cycles do |t|
      t.string :name
      t.references :vendor, null: false, foreign_key: true
      t.string :frequency
      t.integer :day_of_week
      t.integer :day_of_month
      t.boolean :active

      t.timestamps
    end
  end
end
