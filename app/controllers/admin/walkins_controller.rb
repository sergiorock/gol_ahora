class Admin::WalkinsController < Admin::BaseController
  def new
    authorize :walkin, :new?
    @courts = Court.includes(:court_type).available.order(:name)
    @users  = User.where(role: :client).order(:last_name, :first_name)
    @court_prices = @courts.each_with_object({}) { |c, h| h[c.id.to_s] = c.court_type.price_per_hour.to_f }
  end

  def create
    authorize :walkin, :create?

    court     = Court.find(params[:walkin][:court_id])
    user      = User.find(params[:walkin][:user_id])
    date      = params[:walkin][:date]
    starts_at = Time.zone.parse("#{date} #{params[:walkin][:start_time]}")
    ends_at   = Time.zone.parse("#{date} #{params[:walkin][:end_time]}")
    hours     = ((ends_at - starts_at) / 3600.0)
    amount    = params[:walkin][:amount].presence&.to_d || (court.court_type.price_per_hour * hours).ceil(2)

    reservation = user.reservations.new(
      court:      court,
      starts_at:  starts_at,
      ends_at:    ends_at,
      total_amount:   amount,
      deposit_amount: 0
    )

    unless reservation.valid?
      flash.now[:alert] = reservation.errors.full_messages.to_sentence
      @courts = Court.includes(:court_type).available.order(:name)
      @users  = User.where(role: :client).order(:last_name, :first_name)
      @court_prices = @courts.each_with_object({}) { |c, h| h[c.id.to_s] = c.court_type.price_per_hour.to_f }
      return render :new, status: :unprocessable_entity
    end

    court.with_lock do
      reservation.save!

      charge = reservation.create_balance_charge!(
        user:           user,
        amount:         amount,
        concept:        "Alquiler #{court.name} #{l starts_at, format: '%-d/%m/%Y %H:%M'}",
        charge_type:    :rental,
        payment_method: params[:walkin][:payment_method],
        date:           Date.today
      )
      charge.create_receipt!(concept: charge.concept)

      raise ActiveRecord::RecordInvalid.new(reservation) unless reservation.confirm!
    end

    redirect_to admin_charges_path, notice: "Reserva presencial registrada y recibo generado."
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.message
    @courts = Court.includes(:court_type).available.order(:name)
    @users  = User.where(role: :client).order(:last_name, :first_name)
    @court_prices = @courts.each_with_object({}) { |c, h| h[c.id.to_s] = c.court_type.price_per_hour.to_f }
    render :new, status: :unprocessable_entity
  end
end
