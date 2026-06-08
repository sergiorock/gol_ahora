class CourtsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @sizes    = CourtType.order(:capacity).distinct.pluck(:capacity).map { |c| c / 2 }
    @surfaces = CourtType.distinct.pluck(:surface).uniq.compact.sort

    @courts = Court.includes(:court_type).available.order(:name)
    @courts = @courts.joins(:court_type).where(court_types: { capacity: params[:size].to_i * 2 }) if params[:size].present?
    @courts = @courts.joins(:court_type).where(court_types: { surface: params[:surface] }) if params[:surface].present?

    authorize @courts
  end

  def show
    @court = Court.includes(:court_type).find(params[:id])
    authorize @court
  end

  def availability
    @court = Court.find(params[:id])
    authorize @court, :show?

    date = Date.parse(params[:date]) rescue Date.today

    reservations = Reservation.where(court_id: @court.id)
                               .where.not(status: %w[cancelled])
                               .where("DATE(starts_at AT TIME ZONE 'America/Argentina/Buenos_Aires') = ?", date)
                               .pluck(:starts_at, :ends_at)
                               .map { |s, e| { from: s.strftime("%H:%M"), to: e.strftime("%H:%M") } }

    blocks = CourtBlock.where(court_id: @court.id)
                       .where("starts_at < ? AND ends_at > ?",
                              date.end_of_day, date.beginning_of_day)
                       .pluck(:starts_at, :ends_at)
                       .map { |s, e| { from: [s, date.beginning_of_day].max.strftime("%H:%M"),
                                       to:   [e, date.end_of_day].min.strftime("%H:%M") } }

    render json: {
      unavailable:          reservations + blocks,
      max_duration_minutes: @court.court_type.max_duration_minutes
    }
  end
end
