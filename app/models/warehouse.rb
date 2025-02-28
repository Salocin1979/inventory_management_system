class Warehouse < ApplicationRecord
  has_many :items

  validates :name, :location, presence: true
  validates :name, uniqueness: true
end
