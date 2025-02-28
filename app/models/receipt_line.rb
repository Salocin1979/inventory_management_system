class ReceiptLine < ApplicationRecord
  belongs_to :receipt
  belongs_to :order_line
  belongs_to :item
  belongs_to :unit_of_measure

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_save :calculate_total

  private

  def calculate_total
    self.total = quantity * price
  end
end
