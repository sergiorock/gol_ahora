class Admin::ReservationsController < Admin::BaseController
  before_action :set_reservation, only: %i[show update]

  def index
    @reservations = policy_scope(Reservation).includes(:user, :court)
    @reservations = @reservations.where(status: params[:status])    if params[:status].present?
    @reservations = @reservations.where(court_id: params[:court_id]) if params[:court_id].present?
    @reservations = @reservations.where("starts_at >= ?", params[:from].to_date) if params[:from].present?
    @reservations = @reservations.order(starts_at: :desc)
    authorize @reservations
  end

  def show
    authorize @reservation
    @payments = @reservation.payments
  end

  def update
    authorize @reservation
    new_status = params[:reservation][:status]
    event = status_event(new_status)

    if event && @reservation.send(:"may_#{event}?")
      @reservation.send(:"#{event}!")
      redirect_to admin_reservation_path(@reservation), notice: "Estado actualizado."
    else
      redirect_to admin_reservation_path(@reservation), alert: "No se puede cambiar a ese estado."
    end
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def status_event(status)
    { "confirmed" => :confirm, "in_progress" => :start, "finished" => :finish, "cancelled" => :cancel }[status]
  end
end
