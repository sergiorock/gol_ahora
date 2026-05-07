class Admin::ReservationsController < Admin::BaseController
  before_action :set_reservation, only: %i[show edit update]

  def index
    @reservations = policy_scope(Reservation).includes(:user, :court)
    @reservations = @reservations.where(status: params[:status])     if params[:status].present?
    @reservations = @reservations.where(court_id: params[:court_id]) if params[:court_id].present?
    @reservations = @reservations.where("starts_at >= ?", params[:from].to_date) if params[:from].present?
    @reservations = @reservations.order(starts_at: :desc)
    authorize @reservations
  end

  def show
    authorize @reservation
    @payments = @reservation.payments
  end

  def edit
    authorize @reservation
    @courts = Court.includes(:court_type).available.order(:name)
  end

  def update
    authorize @reservation

    if params[:reservation][:status].present?
      update_status
    else
      update_data
    end
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def update_status
    event = status_event(params[:reservation][:status])
    if event && @reservation.send(:"may_#{event}?")
      @reservation.send(:"#{event}!")
      redirect_to admin_reservation_path(@reservation), notice: "Estado actualizado."
    else
      redirect_to admin_reservation_path(@reservation), alert: "No se puede cambiar a ese estado."
    end
  end

  def update_data
    r = params[:reservation]
    date      = r[:date].presence
    starts_at = date ? Time.zone.parse("#{date} #{r[:start_time]}") : @reservation.starts_at
    ends_at   = date ? Time.zone.parse("#{date} #{r[:end_time]}")   : @reservation.ends_at

    @reservation.assign_attributes(
      court_id:  r[:court_id],
      starts_at: starts_at,
      ends_at:   ends_at,
      notes:     r[:notes]
    )
    @reservation.total_amount   = calculate_total(@reservation)
    @reservation.deposit_amount = (@reservation.total_amount * Reservation::DEPOSIT_RATIO).ceil(2)

    if @reservation.save
      redirect_to admin_reservation_path(@reservation), notice: "Reserva actualizada."
    else
      @courts = Court.includes(:court_type).available.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def status_event(status)
    { "confirmed" => :confirm, "in_progress" => :start, "finished" => :finish, "cancelled" => :cancel }[status]
  end

  def calculate_total(reservation)
    return 0 unless reservation.court && reservation.starts_at && reservation.ends_at
    hours = reservation.duration_minutes / 60.0
    (reservation.court.court_type.price_per_hour * hours).ceil(2)
  end
end
