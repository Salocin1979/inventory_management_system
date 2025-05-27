# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  def index
    @cost_center = current_cost_center

    # Basic KPIs - Use the working methods you already have
    @total_inventory_value = calculate_total_inventory_value
    @inventory_turnover = calculate_turnover
    @avg_order_cycle = calculate_avg_cycle_time

    # Dashboard sections - Use the working methods you already have
    @low_stock_items = fetch_low_stock_items
    @recent_transactions = fetch_recent_receipts # Use receipts instead of StockTransaction
    @pending_orders = fetch_pending_orders

    # Chart data
    @inventory_by_category = calculate_inventory_by_category
    @transactions_history = calculate_transactions_history
  end

  private

  def current_cost_center
    # Ensure a default cost center exists for standalone operation or testing
    CostCenter.find_by(code: 'WH001') || CostCenter.first || CostCenter.create!(
      code: 'WH001',
      name: 'Main Warehouse',
      description: 'Default warehouse for dashboard',
      active: true
    )
  end

  def calculate_total_inventory_value
    return 0 unless @cost_center
    # Inventory stores quantity and links to Item (for unit_cost) and CostCenter.
    Inventory.joins(:item)
             .where(inventories: { cost_center_id: @cost_center.id })
             .sum('inventories.quantity * items.unit_cost')
  rescue StandardError => e
    Rails.logger.error "Error calculating total inventory value: #{e.message}"
    0
  end

  # Add these missing methods that your original code was trying to call
  def calculate_turnover
    # Placeholder - implement based on your business logic
    # This could be cost of goods sold / average inventory value
    0
  rescue StandardError => e
    Rails.logger.error "Error calculating inventory turnover: #{e.message}"
    0
  end

  def calculate_avg_cycle_time
    # Placeholder - implement based on your business logic
    # This could be average time from order to receipt
    0
  rescue StandardError => e
    Rails.logger.error "Error calculating average cycle time: #{e.message}"
    0
  end

  LowStockEntry = Struct.new(:item, :current_quantity, :category_name, :reorder_point)

  def fetch_low_stock_items(limit = 10)
    return [] unless @cost_center

    inventories = Inventory.joins(item: :category)
                           .includes(item: :category) # Eager load item and its category
                           .where(inventories: { cost_center_id: @cost_center.id })
                           .where('inventories.quantity < items.reorder_point')
                           .order('inventories.quantity ASC')
                           .limit(limit)

    inventories.map do |inventory_record|
      LowStockEntry.new(
        inventory_record.item,
        inventory_record.quantity,
        inventory_record.item.category&.name,
        inventory_record.item.reorder_point
      )
    end
  rescue StandardError => e
    Rails.logger.error "Error fetching low stock items: #{e.message}"
    []
  end

  def fetch_pending_orders(limit = 10)
    return [] unless @cost_center
    Order.where(cost_center: @cost_center, status: 'pending')
         .order(order_date: :desc)
         .limit(limit)
  rescue StandardError => e
    Rails.logger.error "Error fetching pending orders: #{e.message}"
    []
  end

  def fetch_recent_receipts(limit = 5)
    return [] unless @cost_center
    # Assuming Receipt belongs_to cost_center
    Receipt.where(cost_center: @cost_center)
           .order(receipt_date: :desc)
           .limit(limit)
  rescue StandardError => e
    Rails.logger.error "Error fetching recent receipts: #{e.message}"
    []
  end

  def calculate_inventory_by_category
    return {} unless @cost_center
    # Inventory joins Item, Item belongs_to Category. Calculate value per category.
    Inventory.joins(item: :category)
             .where(inventories: { cost_center_id: @cost_center.id })
             .group('categories.name')
             .sum('inventories.quantity * items.unit_cost')
             .tap { |data| Rails.logger.info "Inventory by Category: #{data.inspect}" }
  rescue StandardError => e
    Rails.logger.error "Error calculating inventory by category: #{e.message}"
    {}
  end

  def calculate_transactions_history
    labels = 6.downto(0).map { |i| i.months.ago.beginning_of_month.strftime('%b %Y') }
    incoming_data = Array.new(7, 0)
    outgoing_data = Array.new(7, 0) # Placeholder for outgoing

    return { labels: labels, incoming: incoming_data, outgoing: outgoing_data } unless @cost_center

    begin
      # Incoming transactions (Receipts)
      receipts_by_month = Receipt.includes(:receipt_lines)
                                 .where(cost_center: @cost_center)
                                 .where(receipt_date: 7.months.ago.beginning_of_month..Time.current.end_of_month)
                                 .group_by { |r| r.receipt_date.beginning_of_month }

      labels.each_with_index do |month_label, index|
        month_start = Time.zone.parse(month_label)
        receipts_for_month = receipts_by_month[month_start] || []
        incoming_data[index] = receipts_for_month.sum { |r| r.receipt_lines.sum(&:total) }
      end
    rescue StandardError => e
      Rails.logger.error "Error calculating transactions history: #{e.message}"
      # Return empty data on error to prevent chart rendering issues
      incoming_data = Array.new(7, 0)
    end

    {
      labels: labels,
      incoming: incoming_data,
      outgoing: outgoing_data
    }
  end
end
