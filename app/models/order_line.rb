class OrderLine < ApplicationRecord
  belongs_to :order
  belongs_to :item
  belongs_to :unit_of_measure

  has_many :receipt_lines

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_save :calculate_total

  private

  def calculate_total
    self.total = quantity * price
  end
end
