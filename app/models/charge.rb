class Charge < ApplicationRecord
  belongs_to :user
  belongs_to :discount, optional: true
  belongs_to :reservation, optional: true
  has_one :receipt, dependent: :destroy

  enum :charge_type, { rental: 0, enrollment: 1, class_fee: 2, other: 3 }
  enum :payment_method, { cash: 0, transfer: 1, card: 2 }

  validates :concept, :amount, :charge_type, :payment_method, :date, presence: true
  validates :amount, numericality: { greater_than: 0 }
  scope :deposits, -> { where(is_deposit: true) }
  scope :balances, -> { where(is_deposit: false) }

  after_create :finalize_reservation_if_balance
  before_save :apply_discount

  private

  def finalize_reservation_if_balance
    return unless reservation&.may_finish?
    reservation.finish!
  end

  def apply_discount
    return unless discount && discount.active?
    self.amount = discount.apply_to(amount_before_type_cast.to_d)
  end
end
