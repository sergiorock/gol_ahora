class Admin::CourtsController < Admin::BaseController
  before_action :set_court, only: %i[show edit update destroy]

  def index
    @courts = Court.includes(:court_type).order(:name)
    authorize @courts
  end

  def show
    authorize @court
    @upcoming_blocks = @court.court_blocks.where("ends_at > ?", Time.current).order(:starts_at)
  end

  def new
    @court = Court.new
    authorize @court
  end

  def create
    @court = Court.new(court_params)
    authorize @court
    if @court.save
      redirect_to admin_court_path(@court), notice: "Cancha creada correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @court
  end

  def update
    authorize @court
    if @court.update(court_params)
      redirect_to admin_court_path(@court), notice: "Cancha actualizada correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @court
    @court.destroy
    redirect_to admin_courts_path, notice: "Cancha eliminada."
  end

  private

  def set_court
    @court = Court.find(params[:id])
  end

  def court_params
    params.require(:court).permit(:name, :description, :status, :court_type_id)
  end
end
