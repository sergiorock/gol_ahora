class Admin::DashboardController < Admin::BaseController
  def index
    today     = Time.zone.today
    mes_inicio = today.beginning_of_month
    mes_fin    = today.end_of_month

    @stats = {
      users:               User.where(role: :client).count,
      courts:              Court.active.count,
      reservations_today:  Reservation.where("DATE(starts_at) = ?", today).where.not(status: :cancelled).count,
      confirmed_this_month: Reservation.where(status: :confirmed)
                                        .where(starts_at: mes_inicio..mes_fin)
                                        .count,
      ingresos_mes:        Charge.where(date: mes_inicio..mes_fin).sum(:amount),
      asistencias_mes:     Asistencia.where(attended_on: mes_inicio..mes_fin).count,
      clases_activas:      Clase.where(status: :activa).count,
      entrenamientos_activos: Entrenamiento.where(status: :activo).count
    }

    @recent_reservations = Reservation.includes(:user, :court)
                                      .order(created_at: :desc)
                                      .limit(8)

    @upcoming_today = Reservation.includes(:user, :court)
                                 .where("DATE(starts_at) = ?", today)
                                 .where(status: %w[confirmed in_progress])
                                 .order(:starts_at)

    @recent_charges = Charge.includes(:user)
                            .order(created_at: :desc)
                            .limit(5)
  end
end
