class StockTransaction < ApplicationRecord
  belongs_to :item
  belongs_to :supplier, optional: true
  belongs_to :user

  validates :transaction_type, presence: true, inclusion: { in: ['stock_in', 'stock_out'] }
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }, if: :stock_in?
  validates :supplier, presence: true, if: :stock_in?
  validate :sufficient_stock, if: :stock_out?

  before_save :calculate_total_price
  after_create :update_item_stock

  def stock_in?
    transaction_type == 'stock_in'
  end

  def stock_out?
    transaction_type == 'stock_out'
  end

  private

  def calculate_total_price
    self.total_price = quantity * unit_price if stock_in?
  end

  def update_item_stock
    if stock_in?
      item.update(current_stock: item.current_stock + quantity)
    elsif stock_out?
      item.update(current_stock: item.current_stock - quantity)
    end
  end

  def sufficient_stock
    if item.current_stock < quantity
      errors.add(:quantity, "exceeds available stock (#{item.current_stock})")
    end
  end
end
