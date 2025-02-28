class AllowNullParentCostCenter < ActiveRecord::Migration[8.0]
  def change
    change_column_null :cost_centers, :parent_cost_center_id, true
  end
end
