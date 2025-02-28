class CreateReceipts < ActiveRecord::Migration[8.0]
  def change
    create_table :receipts do |t|
      t.string :receipt_number
      t.references :order, null: false, foreign_key: true
      t.references :vendor, null: false, foreign_key: true
      t.references :cost_center, null: false, foreign_key: true
      t.references :received_by, null: false, foreign_key: true
      t.datetime :receipt_date
      t.string :status
      t.text :notes
      t.decimal :total_amount

      t.timestamps
    end
  end
end
