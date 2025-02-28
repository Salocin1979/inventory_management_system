class CreateStockTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_transactions do |t|
      t.references :item, null: false, foreign_key: true
      t.string :transaction_type
      t.integer :quantity
      t.decimal :unit_price
      t.decimal :total_price
      t.string :reference_number
      t.text :notes
      t.references :supplier, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
