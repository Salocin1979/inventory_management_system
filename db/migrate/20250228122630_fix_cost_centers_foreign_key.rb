class FixCostCentersForeignKey < ActiveRecord::Migration[8.0]
  # Remove the existing foreign key if it exists
  remove_foreign_key :cost_centers, :parent_cost_centers, if_exists: true

  # Add the correct self-referential foreign key
  add_foreign_key :cost_centers, :cost_centers, column: :parent_cost_center_id, if_exists: true
end
