class CourtType < ApplicationRecord
  has_many :courts, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :capacity, presence: true, numericality: { greater_than: 0 }
  validates :max_duration_minutes, presence: true, numericality: { greater_than: 0 }
  validates :price_per_hour, presence: true, numericality: { greater_than: 0 }

  def duration_label
    h = max_duration_minutes / 60
    m = max_duration_minutes % 60
    m > 0 ? "#{h}h #{m}min" : "#{h}h"
  end
end
