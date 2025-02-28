class Order < ApplicationRecord
  belongs_to :vendor, class_name: 'Supplier', foreign_key: 'vendor_id'
  belongs_to :cost_center
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  belongs_to :approved_by, class_name: 'User', foreign_key: 'approved_by_id', optional: true
  belongs_to :order_cycle

  has_many :order_lines, dependent: :destroy
  has_many :receipts

  accepts_nested_attributes_for :order_lines, allow_destroy: true, reject_if: :all_blank

  validates :order_number, presence: true, uniqueness: true
  validates :order_date, presence: true
  validates :status, presence: true

  before_save :calculate_total_amount

  private

  def calculate_total_amount
    self.total_amount = order_lines.sum(&:total) || 0
  end
end
