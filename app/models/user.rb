class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { admin: 0, cliente: 1 }, default: :cliente

  # Relaciones (diagrama: Usuario tiene historial de reservas, asistencias, inscripciones, equipos)
  has_many :reservas, dependent: :destroy
  has_many :asistencias, dependent: :destroy
  has_many :inscripciones, dependent: :destroy
  has_many :equipos, dependent: :destroy

  validates :nombres, presence: true
  validates :apellido, presence: true
  validates :dni, uniqueness: true, allow_blank: true

  def nombre_completo
    "#{nombres} #{apellido}"
  end

  def admin?
    role == "admin"
  end

  def cliente?
    role == "cliente"
  end
end
