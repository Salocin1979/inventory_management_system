# app/controllers/items_controller.rb
class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  def index
    @q = Item.ransack(params[:q])
    @items = @q.result.includes(:item_group, :unit_of_measure)
                     .page(params[:page])
                     .per(20)
  end

  def show
    @inventories = @item.inventories.includes(:cost_center, :storage_location)
    @vendor_purchase_items = @item.vendor_purchase_items.includes(:vendor, :purchase_unit)
    @recent_orders = @item.order_lines.includes(:order).order(created_at: :desc).limit(5)
    @recent_receipts = @item.receipt_lines.includes(:receipt).order(created_at: :desc).limit(5)

    # Item movement history
    @movement_history = prepare_movement_history

    # Stock level chart data
    @stock_level_history = prepare_stock_level_history
  end

  def new
    @item = Item.new

    @item_groups = ItemGroup.all
    @units_of_measure = UnitOfMeasure.all
  end

  def create
    @item = Item.new(item_params)

    if @item.save
      redirect_to @item, notice: 'Item was successfully created.'
    else
      @item_groups = ItemGroup.all
      @units_of_measure = UnitOfMeasure.all
      render :new
    end
  end

  def edit
    @item_groups = ItemGroup.all
    @units_of_measure = UnitOfMeasure.all
  end

  def update
    if @item.update(item_params)
      redirect_to @item, notice: 'Item was successfully updated.'
    else
      @item_groups = ItemGroup.all
      @units_of_measure = UnitOfMeasure.all
      render :edit
    end
  end

  def destroy
    if @item.destroy
      redirect_to items_path, notice: 'Item was successfully deleted.'
    else
      redirect_to @item, alert: 'Could not delete item. It may be referenced by other records.'
    end
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(
      :code, :name, :description, :item_group_id, :unit_of_measure_id,
      :price, :active, :purchasable, :sellable, :barcode,
      :reorder_point, :reorder_quantity, :minimum_stock, :maximum_stock
    )
  end

  def prepare_movement_history
    # Combine receipts, transfers, and waste records
    receipts = ReceiptLine.where(item: @item)
                         .joins(:receipt)
                         .where(receipts: { cost_center: current_cost_center })
                         .order('receipts.receipt_date DESC')
                         .limit(10)
                         .map do |line|
                           {
                             date: line.receipt.receipt_date,
                             type: 'Receipt',
                             document: line.receipt.receipt_number,
                             quantity: line.quantity,
                             direction: 'in'
                           }
                         end

    transfers_in = TransferLine.where(item: @item)
                              .joins(:transfer)
                              .where(transfers: { destination_cost_center: current_cost_center })
                              .order('transfers.transfer_date DESC')
                              .limit(10)
                              .map do |line|
                                {
                                  date: line.transfer.transfer_date,
                                  type: 'Transfer In',
                                  document: line.transfer.transfer_number,
                                  quantity: line.quantity,
                                  direction: 'in'
                                }
                              end

    transfers_out = TransferLine.where(item: @item)
                               .joins(:transfer)
                               .where(transfers: { source_cost_center: current_cost_center })
                               .order('transfers.transfer_date DESC')
                               .limit(10)
                               .map do |line|
                                 {
                                   date: line.transfer.transfer_date,
                                   type: 'Transfer Out',
                                   document: line.transfer.transfer_number,
                                   quantity: line.quantity,
                                   direction: 'out'
                                 }
                               end

    waste = WasteLine.where(item: @item)
                    .joins(:waste)
                    .where(wastes: { cost_center: current_cost_center })
                    .order('wastes.waste_date DESC')
                    .limit(10)
                    .map do |line|
                      {
                        date: line.waste.waste_date,
                        type: 'Waste',
                        document: line.waste.waste_number,
                        quantity: line.quantity,
                        direction: 'out'
                      }
                    end

    (receipts + transfers_in + transfers_out + waste).sort_by { |h| h[:date] }.reverse.take(20)
  end

  def prepare_stock_level_history
    # Stock level over last 6 months
    months = 6.downto(0).map { |i| i.months.ago.beginning_of_month }

    # This would typically come from inventory snapshots in a real app
    # Here's a simplified version
    stock_levels = months.map do |date|
      {
        date: date.strftime('%b %Y'),
        level: rand(50..100) # Placeholder - real data would come from historical records
      }
    end

    stock_levels
  end

  # Helper method to get current cost center
  def current_cost_center
    @current_cost_center ||= begin
      if session[:cost_center_id].present?
        CostCenter.find_by(id: session[:cost_center_id])
      else
        # Default to first cost center if not set
        CostCenter.first
      end
    end
  end
end
