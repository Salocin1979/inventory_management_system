class CostCenter < ApplicationRecord
  belongs_to :parent_cost_center, class_name: 'CostCenter', optional: true

  has_many :child_cost_centers, class_name: 'CostCenter', foreign_key: 'parent_cost_center_id'
  has_many :storage_locations
  has_many :inventories
  has_many :orders
  has_many :receipts
  has_many :issued_requests_as_requester, class_name: 'IssueRequest', foreign_key: 'requesting_cost_center_id'
  has_many :issued_requests_as_fulfiller, class_name: 'IssueRequest', foreign_key: 'fulfilling_cost_center_id'
  has_many :transfers_as_source, class_name: 'Transfer', foreign_key: 'source_cost_center_id'
  has_many :transfers_as_destination, class_name: 'Transfer', foreign_key: 'destination_cost_center_id'
  has_many :inventory_counts
  has_many :productions
  has_many :wastes

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  scope :active, -> { where(active: true) }

  # Method to get all items and their quantities for this cost center
  def inventory_summary
    inventories.includes(:item)
  end

  # Method to calculate total inventory value
  def total_inventory_value
    inventories.sum { |inv| inv.quantity * inv.item.price }
  end
end
