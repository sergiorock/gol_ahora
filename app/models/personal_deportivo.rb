class PersonalDeportivo < ApplicationRecord
  has_many :clases, dependent: :restrict_with_error
  has_many :entrenamientos, dependent: :restrict_with_error
  has_one_attached :certificacion_archivo

  enum :tipo, { profesor: 0, entrenador: 1 }, prefix: true

  TIPO_LABELS = {
    "profesor"    => "Profesor",
    "entrenador"  => "Entrenador"
  }.freeze

  validates :nombre, :apellido, :tipo, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :fecha_certificacion, comparison: { less_than_or_equal_to: -> { Date.today },
    message: "no puede ser una fecha futura" }, allow_blank: true
  validate :archivo_requerido_si_hay_fecha

  private

  def archivo_requerido_si_hay_fecha
    if fecha_certificacion.present? && !certificacion_archivo.attached?
      errors.add(:certificacion_archivo, "es obligatorio si se indica una fecha de certificación")
    end
  end

  def full_name
    "#{nombre} #{apellido}"
  end
end
