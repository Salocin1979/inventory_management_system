class CreateStorageLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :storage_locations do |t|
      t.string :name
      t.text :description
      t.references :cost_center, null: false, foreign_key: true

      t.timestamps
    end
  end
end
