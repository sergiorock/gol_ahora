class Payment < ApplicationRecord
  belongs_to :reservation

  enum :payment_type, { deposit: 0, full: 1 }
  enum :status, { pending: 0, approved: 1, rejected: 2 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_type, :status, presence: true
  validates :last_four_digits, presence: true, format: { with: /\A\d{4}\z/, message: "deben ser 4 dígitos" }
  validates :cardholder_name, presence: true
  validates :expiry_date, presence: true, format: { with: /\A(0[1-9]|1[0-2])\/\d{2}\z/, message: "debe tener formato MM/AA" }
end
