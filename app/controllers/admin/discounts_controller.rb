class Admin::DiscountsController < Admin::BaseController
  before_action :set_discount, only: %i[show edit update destroy toggle]

  def index
    authorize Discount
    @discounts = policy_scope(Discount).order(:name)
  end

  def show
    authorize @discount
  end

  def new
    @discount = Discount.new(active: true)
    authorize @discount
  end

  def create
    @discount = Discount.new(discount_params)
    authorize @discount

    if @discount.save
      redirect_to admin_discounts_path, notice: "Descuento creado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @discount
  end

  def update
    authorize @discount

    if @discount.update(discount_params)
      redirect_to admin_discounts_path, notice: "Descuento actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @discount
    @discount.destroy
    redirect_to admin_discounts_path, notice: "Descuento eliminado."
  end

  def toggle
    authorize @discount, :update?
    @discount.update!(active: !@discount.active)
    redirect_to admin_discounts_path, notice: "Descuento #{@discount.active? ? 'activado' : 'desactivado'}."
  end

  private

  def set_discount
    @discount = Discount.find(params[:id])
  end

  def discount_params
    params.require(:discount).permit(:name, :discount_type, :value, :condition, :active)
  end
end
