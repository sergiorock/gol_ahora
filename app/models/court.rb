class Court < ApplicationRecord
  belongs_to :court_type
  has_many :court_blocks, dependent: :destroy

  enum :status, { active: 0, inactive: 1, maintenance: 2 }, default: :active

  validates :name, presence: true
  validates :status, presence: true

  scope :available, -> { where(status: :active) }

  def blocked_at?(from, to)
    court_blocks.where("starts_at < ? AND ends_at > ?", to, from).exists?
  end
end
