class Transaction < ApplicationRecord
  belongs_to :item
  belongs_to :cost_center
end
