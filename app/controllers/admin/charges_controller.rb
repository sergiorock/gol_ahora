class Admin::ChargesController < Admin::BaseController
  before_action :set_charge, only: %i[show edit update destroy]

  def index
    authorize Charge
    @charges = policy_scope(Charge).includes(:user, :discount, :receipt).order(created_at: :desc)
    @charges = @charges.where(charge_type: params[:charge_type]) if params[:charge_type].present?
    @charges = @charges.where("date >= ?", params[:from].to_date) if params[:from].present?
  end

  def show
    authorize @charge
  end

  def new
    @charge = Charge.new(
      date:           Date.today,
      user_id:        params[:prefill_user],
      amount:         params[:prefill_amount],
      concept:        params[:prefill_concept],
      charge_type:    params[:prefill_type] || "rental",
      reservation_id: params[:prefill_reservation]
    )
    authorize @charge
    @users     = User.where(role: :client).order(:last_name, :first_name)
    @discounts = Discount.active
  end

  def create
    @charge = Charge.new(charge_params)
    authorize @charge

    if @charge.save
      redirect_to admin_charge_path(@charge), notice: "Cobro registrado."
    else
      @users     = User.where(role: :client).order(:last_name, :first_name)
      @discounts = Discount.active
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @charge
    @users     = User.where(role: :client).order(:last_name, :first_name)
    @discounts = Discount.active
  end

  def update
    authorize @charge

    if @charge.update(charge_params)
      redirect_to admin_charge_path(@charge), notice: "Cobro actualizado."
    else
      @users     = User.where(role: :client).order(:last_name, :first_name)
      @discounts = Discount.active
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @charge
    @charge.destroy
    redirect_to admin_charges_path, notice: "Cobro eliminado."
  end

  private

  def set_charge
    @charge = Charge.find(params[:id])
  end

  def charge_params
    params.require(:charge).permit(:user_id, :discount_id, :reservation_id, :amount,
                                   :concept, :charge_type, :payment_method, :date, :notes)
  end
end
