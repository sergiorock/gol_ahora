class Asistencia < ApplicationRecord
  self.table_name = "asistencias"

  belongs_to :user
  belongs_to :asistible, polymorphic: true

  validates :user_id, uniqueness: { scope: [:asistible_type, :asistible_id],
                                    message: "ya está inscripto en esta actividad" }
  validates :attended_on, presence: true

  scope :present, -> { where(present: true) }
  scope :absent,  -> { where(present: false) }
end
