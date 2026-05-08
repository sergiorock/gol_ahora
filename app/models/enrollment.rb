class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :enrollable, polymorphic: true

  enum :status, { active: 0, cancelled: 1 }

  validates :team_name, presence: true
  validates :enrolled_at, presence: true
  validates :user_id, uniqueness: { scope: [:enrollable_type, :enrollable_id],
                                    message: "ya está inscripto en esta competencia" }

  before_validation :set_enrolled_at, on: :create

  private

  def set_enrolled_at
    self.enrolled_at ||= Time.current
  end
end
