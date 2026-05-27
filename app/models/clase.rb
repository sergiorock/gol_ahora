class Clase < ApplicationRecord
  belongs_to :personal_deportivo
  belongs_to :court_type, optional: true
  has_many :asistencias, as: :asistible, dependent: :destroy

  enum :status, { activa: 0, inactiva: 1 }

  validates :nombre, :scheduled_at, :duration_minutes, :max_students, presence: true
  validates :duration_minutes, :max_students, numericality: { greater_than: 0 }

  def spots_taken
    asistencias.count
  end

  def spots_available
    max_students - spots_taken
  end

  def full?
    spots_available <= 0
  end

  def schedule_label
    return "—" unless scheduled_at
    I18n.l(scheduled_at, format: "%A %-d/%m, %H:%M hs").capitalize
  end
end
