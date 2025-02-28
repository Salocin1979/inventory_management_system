class CreateReceiptLines < ActiveRecord::Migration[8.0]
  def change
    create_table :receipt_lines do |t|
      t.references :receipt, null: false, foreign_key: true
      t.references :order_line, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.decimal :quantity
      t.decimal :price
      t.references :unit_of_measure, null: false, foreign_key: true
      t.decimal :total

      t.timestamps
    end
  end
end
