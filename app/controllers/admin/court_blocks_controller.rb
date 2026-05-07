class Admin::CourtBlocksController < Admin::BaseController
  before_action :set_court
  before_action :set_block, only: %i[edit update destroy]

  def index
    @blocks = @court.court_blocks.order(:starts_at)
    authorize CourtBlock
  end

  def new
    @block = @court.court_blocks.build
    authorize @block
  end

  def create
    @block = @court.court_blocks.build(block_params)
    authorize @block
    if @block.save
      redirect_to admin_court_path(@court), notice: "Bloqueo registrado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @block
  end

  def update
    authorize @block
    if @block.update(block_params)
      redirect_to admin_court_path(@court), notice: "Bloqueo actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @block
    @block.destroy
    redirect_to admin_court_path(@court), notice: "Bloqueo eliminado."
  end

  private

  def set_court
    @court = Court.find(params[:court_id])
  end

  def set_block
    @block = @court.court_blocks.find(params[:id])
  end

  def block_params
    params.require(:court_block).permit(:starts_at, :ends_at, :reason)
  end
end
