class Supplier < ApplicationRecord
  has_many :stock_transactions

  validates :name, :contact_person, :email, :phone, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
