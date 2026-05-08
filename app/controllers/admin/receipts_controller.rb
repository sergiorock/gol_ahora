class Admin::ReceiptsController < Admin::BaseController
  before_action :set_receipt, only: %i[show edit update destroy pdf]

  def index
    authorize Receipt
    @receipts = policy_scope(Receipt).includes(charge: :user).order(issued_at: :desc)
  end

  def show
    authorize @receipt
  end

  def pdf
    authorize @receipt, :show?
    data = ReceiptPdf.new(@receipt).render
    send_data data,
      filename: "recibo-#{@receipt.receipt_number}.pdf",
      type: "application/pdf",
      disposition: "inline"
  end

  def new
    @charge  = Charge.find(params[:charge_id]) if params[:charge_id]
    @receipt = Receipt.new(charge: @charge, concept: @charge&.concept, issued_at: Time.current)
    authorize @receipt
    @charges = Charge.includes(:user).where.not(id: Receipt.select(:charge_id)).order(date: :desc)
  end

  def create
    @receipt = Receipt.new(receipt_params)
    authorize @receipt

    if @receipt.save
      redirect_to admin_receipt_path(@receipt), notice: "Recibo generado: #{@receipt.receipt_number}."
    else
      @charges = Charge.includes(:user).where.not(id: Receipt.select(:charge_id)).order(date: :desc)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @receipt
    @charges = Charge.includes(:user).order(date: :desc)
  end

  def update
    authorize @receipt

    if @receipt.update(receipt_params)
      redirect_to admin_receipt_path(@receipt), notice: "Recibo actualizado."
    else
      @charges = Charge.includes(:user).order(date: :desc)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @receipt
    @receipt.destroy
    redirect_to admin_receipts_path, notice: "Recibo eliminado."
  end

  private

  def set_receipt
    @receipt = Receipt.find(params[:id])
  end

  def receipt_params
    params.require(:receipt).permit(:charge_id, :concept, :issued_at)
  end
end
