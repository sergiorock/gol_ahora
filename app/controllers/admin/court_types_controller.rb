class Admin::CourtTypesController < Admin::BaseController
  before_action :set_court_type, only: %i[show edit update destroy]

  def index
    @court_types = CourtType.all.order(:name)
    authorize @court_types
  end

  def show
    authorize @court_type
  end

  def new
    @court_type = CourtType.new
    authorize @court_type
  end

  def create
    @court_type = CourtType.new(court_type_params)
    authorize @court_type
    if @court_type.save
      redirect_to admin_court_types_path, notice: "Tipo de cancha creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @court_type
  end

  def update
    authorize @court_type
    if @court_type.update(court_type_params)
      redirect_to admin_court_types_path, notice: "Tipo de cancha actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @court_type
    @court_type.destroy
    redirect_to admin_court_types_path, notice: "Tipo de cancha eliminado."
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to admin_court_types_path, alert: "No se puede eliminar: tiene canchas asociadas."
  end

  private

  def set_court_type
    @court_type = CourtType.find(params[:id])
  end

  def court_type_params
    params.require(:court_type).permit(:name, :surface, :capacity, :max_duration_minutes, :price_per_hour)
  end
end
