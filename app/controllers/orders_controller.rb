class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :edit, :update, :destroy, :approve]

  def index
    @orders = Order.all.order(created_at: :desc)
  end

  def show
    @order_lines = @order.order_lines.includes(:item, :unit_of_measure)
  end

  def new
    @order = Order.new
    @order.order_lines.build
    @order.order_date = Date.today
    @order.status = 'draft'

    load_form_data
  end

  def create
    @order = Order.new(order_params)
    @order.created_by_id = current_user.id

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        load_form_data
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    load_form_data
  end

  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        load_form_data
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_path, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def approve
    if @order.status == 'pending'
      @order.update(status: 'approved', approved_by_id: current_user.id)
      redirect_to @order, notice: 'Order was successfully approved.'
    else
      redirect_to @order, alert: 'Only pending orders can be approved.'
    end
  end

  private
    def set_order
      @order = Order.find(params[:id])
    end

    def load_form_data
      @vendors = Supplier.all
      @cost_centers = CostCenter.all
      @items = Item.all.includes(:category)
      @users = User.all
      @order_cycles = OrderCycle.all.where(active: true)
      @unit_of_measures = UnitOfMeasure.all
    end

    def order_params
      params.require(:order).permit(
        :order_number,
        :vendor_id,
        :cost_center_id,
        :approved_by_id,
        :order_date,
        :expected_delivery_date,
        :status,
        :notes,
        :total_amount,
        :order_cycle_id,
        order_lines_attributes: [
          :id,
          :item_id,
          :quantity,
          :price,
          :unit_of_measure_id,
          :total,
          :status,
          :_destroy
        ]
      )
    end
end
