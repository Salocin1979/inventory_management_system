class CreateSuppliers < ActiveRecord::Migration[8.0]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.string :contact_person
      t.string :email
      t.string :phone
      t.text :address
      t.string :tax_id
      t.string :payment_terms
      t.text :notes

      t.timestamps
    end
  end
end
