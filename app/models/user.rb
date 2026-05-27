class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { admin: 0, client: 1 }, default: :client

  has_many :reservations,  dependent: :destroy
  has_many :charges,       dependent: :destroy
  has_many :enrollments,   dependent: :destroy
  has_many :asistencias, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :dni, uniqueness: true, allow_blank: true
  validate  :must_be_of_legal_age

  def age
    return nil unless birth_date
    today = Date.today
    years = today.year - birth_date.year
    years -= 1 if today < birth_date + years.years
    years
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def must_be_of_legal_age
    return unless birth_date
    errors.add(:birth_date, "debes ser mayor de 18 años para registrarte") if age < 18
  end

  public

  def admin?
    role == "admin"
  end

  def client?
    role == "client"
  end
end
