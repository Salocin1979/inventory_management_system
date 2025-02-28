class Receipt < ApplicationRecord
  belongs_to :order
  belongs_to :vendor, class_name: 'Supplier', foreign_key: 'vendor_id'
  belongs_to :cost_center
  belongs_to :received_by, class_name: 'User', foreign_key: 'received_by_id'

  has_many :receipt_lines, dependent: :destroy
  accepts_nested_attributes_for :receipt_lines,
                               allow_destroy: true,
                               reject_if: proc { |attributes| attributes['item_id'].blank? }

  validates :receipt_number, presence: true, uniqueness: true
  validates :receipt_date, presence: true
  validates :status, presence: true

  before_save :calculate_total_amount

  private

  def calculate_total_amount
    self.total_amount = receipt_lines.sum(&:total)
  end
end
