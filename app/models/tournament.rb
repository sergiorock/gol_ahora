class Tournament < ApplicationRecord
  has_many :matches, as: :competition, dependent: :destroy
  has_many :enrollments, as: :enrollable, dependent: :destroy

  enum :format, { single_elimination: 0, groups: 1, round_robin: 2 }
  enum :status, { open: 0, in_progress: 1, finished: 2 }

  validates :name, :format, presence: true

  scope :current,    -> { where(status: %i[open in_progress]) }
  scope :historical, -> { where(status: :finished) }

  FORMAT_LABELS = {
    "single_elimination" => "Eliminación directa",
    "groups"             => "Fase de grupos",
    "round_robin"        => "Round robin"
  }.freeze

  def status_label
    { "open" => "Abierto", "in_progress" => "En curso", "finished" => "Finalizado" }[status]
  end
end
