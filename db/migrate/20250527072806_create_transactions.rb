class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :item, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :cost
      t.string :transaction_type
      t.references :cost_center, null: false, foreign_key: true

      t.timestamps
    end
  end
end
