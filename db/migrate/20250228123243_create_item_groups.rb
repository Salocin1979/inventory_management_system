class CreateItemGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :item_groups do |t|
      t.string :name
      t.text :description
      t.references :major_group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
