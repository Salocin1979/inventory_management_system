class Inventory < ApplicationRecord
  belongs_to :item
  belongs_to :cost_center
  belongs_to :storage_location
end
