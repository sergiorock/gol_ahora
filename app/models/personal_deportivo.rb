class PersonalDeportivo < ApplicationRecord
  has_many :clases, dependent: :restrict_with_error
  has_many :entrenamientos, dependent: :restrict_with_error

  enum :tipo, { profesor: 0, entrenador: 1 }, prefix: true

  TIPO_LABELS = {
    "profesor"    => "Profesor",
    "entrenador"  => "Entrenador"
  }.freeze

  validates :nombre, :apellido, :tipo, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  def full_name
    "#{nombre} #{apellido}"
  end
end
