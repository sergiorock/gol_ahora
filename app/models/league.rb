class League < ApplicationRecord
  has_many :matches, as: :competition, dependent: :destroy
  has_many :enrollments, as: :enrollable, dependent: :destroy

  enum :status, { open: 0, in_progress: 1, finished: 2 }

  validates :name, presence: true

  scope :current,    -> { where(status: %i[open in_progress]) }
  scope :historical, -> { where(status: :finished) }

  def status_label
    { "open" => "Abierta", "in_progress" => "En curso", "finished" => "Finalizada" }[status]
  end
end
