class Match < ApplicationRecord
  belongs_to :competition, polymorphic: true
  belongs_to :court, optional: true

  validates :home_team, :away_team, presence: true

  def played?
    home_goals.present? && away_goals.present?
  end

  def result
    return "—" unless played?
    "#{home_goals} – #{away_goals}"
  end

  def winner
    return nil unless played?
    return :draw if home_goals == away_goals
    home_goals > away_goals ? :home : :away
  end
end
