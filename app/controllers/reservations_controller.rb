class ReservationsController < ApplicationController
  before_action :set_reservation, only: %i[show cancel]

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
    @payment = Payment.new
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

    @payment = Payment.new(
      reservation: @reservation,
      payment_type: :deposit,
      amount: @reservation.deposit_amount,
      status: :approved,
      **payment_params.to_h.symbolize_keys
    )

    if @reservation.valid? && @payment.valid?
      begin
        # Lock the court row to serialize concurrent reservation attempts for the same court
        @court.with_lock do
          ActiveRecord::Base.transaction do
            @reservation.save!
            @payment.reservation = @reservation
            @payment.save!

            # Confirm only if we have evidence of approved deposit
            if @reservation.deposit_paid?
              @reservation.confirm!
            end
          end
        end

        if @reservation.confirmed?
          redirect_to @reservation, notice: "¡Reserva confirmada! Tu seña fue procesada exitosamente."
        else
          redirect_to @reservation, notice: "Reserva creada. Seña pendiente: la reserva permanece en estado pendiente hasta validar el pago."
        end
      rescue ActiveRecord::RecordInvalid => _e
        render :new, status: :unprocessable_entity
      rescue ActiveRecord::StatementInvalid => e
        # Manejo genérico de violaciones de constraint (p. ej. exclusion constraint de solapamiento)
        @reservation.errors.add(:base, "No se pudo crear la reserva: otra reserva ocupó ese horario. Intentá nuevamente.")
        render :new, status: :unprocessable_entity
      end
    else
      render :new, status: :unprocessable_entity
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
