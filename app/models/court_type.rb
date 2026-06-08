class CourtType < ApplicationRecord
  has_many :courts, dependent: :restrict_with_error

  enum :surface, {
    synthetic: "synthetic",
    natural:   "natural",
    parquet:   "parquet",
    cement:    "cement"
  }

  SURFACE_LABELS = {
    "synthetic" => "Césped sintético",
    "natural"   => "Césped natural",
    "parquet"   => "Parquet",
    "cement"    => "Cemento"
  }.freeze

  validates :name, presence: true, uniqueness: { scope: :surface, message: "ya existe un tipo con ese nombre y superficie" }
  validates :surface, presence: true
  validates :capacity, presence: true, numericality: { greater_than: 0, even: true, message: "debe ser par (dos equipos iguales)" }
  validates :max_duration_minutes, presence: true, numericality: { greater_than: 0 }
  validates :price_per_hour, presence: true, numericality: { greater_than: 0 }

  def duration_label
    h = max_duration_minutes / 60
    m = max_duration_minutes % 60
    m > 0 ? "#{h}h #{m}min" : "#{h}h"
  end
end
