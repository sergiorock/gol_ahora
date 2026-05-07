class CourtBlock < ApplicationRecord
  belongs_to :court

  validates :starts_at, :ends_at, :reason, presence: true
  validate :ends_after_starts

  private

  def ends_after_starts
    return unless starts_at && ends_at
    errors.add(:ends_at, "debe ser posterior a la fecha de inicio") if ends_at <= starts_at
  end
end
