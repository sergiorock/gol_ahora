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
  validates :fecha_certificacion, presence: true, on: :create
  validates :fecha_certificacion, comparison: { less_than_or_equal_to: -> { Date.today },
    message: "la fecha seleccionada no es válida" }, allow_blank: true
  validate :archivo_requerido, on: :create
  validate :archivo_requerido_si_hay_fecha, on: :update

  def full_name
    "#{nombre} #{apellido}"
  end

  def certificacion_valida?
    certificacion_deportiva.present? &&
      fecha_certificacion.present? &&
      certificacion_archivo.attached?
  end

  private

  def archivo_requerido
    unless certificacion_archivo.attached?
      errors.add(:certificacion_archivo, "El archivo de certificación es obligatorio")
    end
  end

  def archivo_requerido_si_hay_fecha
    if fecha_certificacion.present? && !certificacion_archivo.attached?
      errors.add(:certificacion_archivo, "es obligatorio si se indica una fecha de certificación")
    end
  end
end
