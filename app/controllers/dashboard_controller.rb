# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  def index
    @cost_center = current_cost_center

    # Initially just render the view with minimal data
    @low_stock_items = [] # We'll populate this later
    @pending_orders = [] # We'll populate this later
    @recent_transactions = [] # We'll populate this later

    # Basic KPIs
    @total_inventory_value = 0
    @inventory_turnover = 0
    @order_cycle_time = 0

    # Chart data placeholders
    @inventory_by_category = {}
    @transactions_history = {
      labels: 6.downto(0).map { |i| i.months.ago.beginning_of_month.strftime('%b %Y') },
      incoming: [0, 0, 0, 0, 0, 0, 0],
      outgoing: [0, 0, 0, 0, 0, 0, 0]
    }
  end

  private

  def current_cost_center
    CostCenter.find_by(code: 'WH001') || CostCenter.create!(
      code: 'WH001',
      name: 'Main Warehouse',
      description: 'Default warehouse',
      active: true,
      parent_cost_center_id: nil
    )
  end
end
