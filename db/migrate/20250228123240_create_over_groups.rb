class CreateOverGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :over_groups do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
