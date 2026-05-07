class Receipt < ApplicationRecord
  belongs_to :charge

  before_validation :generate_receipt_number, on: :create

  validates :concept, presence: true
  validates :receipt_number, presence: true, uniqueness: true

  private

  def generate_receipt_number
    last = Receipt.maximum(:id).to_i
    self.receipt_number = format("REC-%06d", last + 1)
    self.issued_at      ||= Time.current
    self.concept        ||= charge.concept
  end
end
