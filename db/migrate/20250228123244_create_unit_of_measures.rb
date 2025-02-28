class CreateUnitOfMeasures < ActiveRecord::Migration[8.0]
  def change
    create_table :unit_of_measures do |t|
      t.string :name
      t.string :abbreviation
      t.boolean :is_base
      t.references :base_unit, null: false, foreign_key: true
      t.decimal :conversion_factor

      t.timestamps
    end
  end
end
