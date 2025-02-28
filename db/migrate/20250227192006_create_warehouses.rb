class CreateWarehouses < ActiveRecord::Migration[8.0]
  def change
    create_table :warehouses do |t|
      t.string :name
      t.string :location
      t.string :manager_name
      t.string :contact_email
      t.string :contact_phone

      t.timestamps
    end
  end
end
