class ReceiptsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_receipt, only: [:show, :edit, :update, :destroy]

  def index
    @receipts = Receipt.all
  end

  def show
    @receipt_lines = @receipt.receipt_lines
  end

  def new
    @receipt = Receipt.new
    @receipt.receipt_lines.build  # Initialize at least one empty receipt line
    @orders = Order.where(status: 'approved')
    @vendors = Supplier.all # Using suppliers as vendors
    @cost_centers = CostCenter.all
  end

  def create
    @receipt = Receipt.new(receipt_params)
    @receipt.received_by_id = current_user.id

    respond_to do |format|
      if @receipt.save
        format.html { redirect_to @receipt, notice: 'Receipt was successfully created.' }
        format.json { render :show, status: :created, location: @receipt }
      else
        @orders = Order.where(status: 'approved')
        @vendors = Supplier.all
        @cost_centers = CostCenter.all
        format.html { render :new }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @orders = Order.where(status: 'approved')
    @vendors = Supplier.all
    @cost_centers = CostCenter.all
  end

  def update
    respond_to do |format|
      if @receipt.update(receipt_params)
        format.html { redirect_to @receipt, notice: 'Receipt was successfully updated.' }
        format.json { render :show, status: :ok, location: @receipt }
      else
        @orders = Order.where(status: 'approved')
        @vendors = Supplier.all
        @cost_centers = CostCenter.all
        format.html { render :edit }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @receipt.destroy
    respond_to do |format|
      format.html { redirect_to receipts_path, notice: 'Receipt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_receipt
      @receipt = Receipt.find(params[:id])
    end

    def receipt_params
      params.require(:receipt).permit(
        :receipt_number,
        :order_id,
        :vendor_id,
        :cost_center_id,
        :receipt_date,
        :status,
        :notes,
        :total_amount,
        receipt_lines_attributes: [
          :id,
          :order_line_id,
          :item_id,
          :quantity,
          :price,
          :unit_of_measure_id,
          :total,
          :_destroy
        ]
      )
    end
end
