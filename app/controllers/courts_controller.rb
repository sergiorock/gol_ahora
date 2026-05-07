class CourtsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @sizes    = CourtType.distinct.pluck(:name).uniq.sort_by { |n| n[/\d+/].to_i }
    @surfaces = CourtType.distinct.pluck(:surface).uniq.compact.sort

    @courts = Court.includes(:court_type).available.order(:name)
    @courts = @courts.joins(:court_type).where(court_types: { name: params[:size] })       if params[:size].present?
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
    occupied = Reservation.where(court_id: @court.id)
                           .where.not(status: %w[cancelled])
                           .where("DATE(starts_at AT TIME ZONE 'America/Argentina/Buenos_Aires') = ?", date)
                           .pluck(:starts_at, :ends_at)
                           .map { |s, e| { from: s.strftime("%H:%M"), to: e.strftime("%H:%M") } }

    render json: occupied
  end
end
