class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { admin: 0, client: 1 }, default: :client

  has_many :reservations, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :teams, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :dni, uniqueness: true, allow_blank: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def admin?
    role == "admin"
  end

  def client?
    role == "client"
  end
end
