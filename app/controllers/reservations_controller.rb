class ReservationsController < ApplicationController
  before_action :set_reservation, only: %i[show pay confirm_payment cancel]

  def index
    @reservations = policy_scope(Reservation).includes(:court).order(starts_at: :desc)
    authorize @reservations
  end

  def show
    authorize @reservation
  end

  def new
    @court = Court.find(params[:court_id]) if params[:court_id]
    @reservation = Reservation.new(court: @court)
    authorize @reservation
  end

  def create
    @court = Court.find(params[:reservation][:court_id])
    starts_at, ends_at = parse_datetime_params

    @reservation = current_user.reservations.new(
      court: @court,
      starts_at: starts_at,
      ends_at: ends_at,
      notes: params[:reservation][:notes]
    )
    @reservation.total_amount   = calculate_total(@reservation)
    @reservation.deposit_amount = (@reservation.total_amount * Reservation::DEPOSIT_RATIO).ceil(2)
    authorize @reservation

    if @reservation.save
      redirect_to pay_reservation_path(@reservation), notice: "Reserva creada. Completá el pago de la seña para confirmarla."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def pay
    authorize @reservation, :show?
    @payment = Payment.new(payment_type: :deposit, amount: @reservation.deposit_amount)
  end

  def confirm_payment
    authorize @reservation, :show?

    @payment = @reservation.payments.new(
      payment_type: :deposit,
      amount: @reservation.deposit_amount,
      **payment_params.to_h.symbolize_keys
    )

    # Procesamiento simulado: siempre aprueba
    @payment.status = :approved

    if @payment.save
      @reservation.confirm!
      redirect_to @reservation, notice: "¡Pago aprobado! Tu reserva está confirmada."
    else
      render :pay, status: :unprocessable_entity
    end
  end

  def cancel
    authorize @reservation, :cancel?
    if @reservation.may_cancel?
      @reservation.cancel!
      redirect_to reservations_path, notice: "Reserva cancelada."
    else
      redirect_to @reservation, alert: "No se puede cancelar esta reserva."
    end
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def parse_datetime_params
    r = params[:reservation]
    date = r[:date].presence
    return [nil, nil] unless date
    starts_at = Time.zone.parse("#{date} #{r[:start_time]}")
    ends_at   = Time.zone.parse("#{date} #{r[:end_time]}")
    [ starts_at, ends_at ]
  rescue ArgumentError
    [ nil, nil ]
  end

  def payment_params
    params.require(:payment).permit(:last_four_digits, :cardholder_name, :expiry_date)
  end

  def calculate_total(reservation)
    return 0 unless reservation.court && reservation.starts_at && reservation.ends_at
    hours = reservation.duration_minutes / 60.0
    (reservation.court.court_type.price_per_hour * hours).ceil(2)
  end
end
