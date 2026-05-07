class Admin::DashboardController < Admin::BaseController
  def index
    today = Time.zone.today

    @stats = {
      users:            User.where(role: :client).count,
      courts:           Court.active.count,
      reservations_today: Reservation.where("DATE(starts_at) = ?", today).where.not(status: :cancelled).count,
      confirmed_this_month: Reservation.where(status: :confirmed)
                                       .where(starts_at: today.beginning_of_month..today.end_of_month)
                                       .count
    }

    @recent_reservations = Reservation.includes(:user, :court)
                                      .order(created_at: :desc)
                                      .limit(8)

    @upcoming_today = Reservation.includes(:user, :court)
                                 .where("DATE(starts_at) = ?", today)
                                 .where(status: %w[confirmed in_progress])
                                 .order(:starts_at)
  end
end
