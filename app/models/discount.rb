class Discount < ApplicationRecord
  has_many :charges

  enum :discount_type, { percentage: 0, fixed: 1 }

  validates :name, presence: true
  validates :discount_type, presence: true
  validates :value, presence: true, numericality: { greater_than: 0 }
  validates :value, numericality: { less_than_or_equal_to: 100 }, if: :percentage?

  scope :active, -> { where(active: true) }

  def apply_to(amount)
    return amount unless active?
    percentage? ? amount * (1 - value / 100.0) : [amount - value, 0].max
  end

  def label
    percentage? ? "#{value.to_i}%" : "$#{value.to_i}"
  end
end
