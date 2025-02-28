class Item < ApplicationRecord
  belongs_to :category
  belongs_to :warehouse
  belongs_to :supplier  # Check if this line exists
  has_many :stock_transactions

  validates :name, :sku, presence: true
  validates :sku, :barcode, uniqueness: true
  validates :current_stock, :minimum_stock, :reorder_point, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :unit_cost, numericality: { greater_than_or_equal_to: 0 }

  def self.search(search_term)
    where('lower(name) LIKE ? OR lower(sku) LIKE ?', "%#{search_term.downcase}%", "%#{search_term.downcase}%")
  end
end
