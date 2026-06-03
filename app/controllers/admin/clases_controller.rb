class Admin::ClasesController < Admin::BaseController
  before_action :set_clase, only: %i[show edit update destroy]

  def index
    @clases = Clase.includes(:personal_deportivo, :court_type).order(:scheduled_at)
    authorize @clases
  end

  def show
    authorize @clase
    @asistencias = @clase.asistencias.includes(:user).order("users.last_name")
  end

  def new
    @clase = Clase.new
    authorize @clase
    load_form_data
  end

  def create
    @clase = Clase.new(clase_params)
    authorize @clase
    if @clase.save
      redirect_to admin_clase_path(@clase), notice: "Clase creada."
    else
      load_form_data
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @clase
    load_form_data
  end

  def update
    authorize @clase
    if @clase.update(clase_params)
      redirect_to admin_clase_path(@clase), notice: "Clase actualizada."
    else
      load_form_data
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @clase
    @clase.destroy
    redirect_to admin_clases_path, notice: "Clase eliminada."
  end

  private

  def set_clase
    @clase = Clase.find(params[:id])
  end

  def clase_params
    params.require(:clase).permit(
      :nombre, :descripcion, :scheduled_at, :duration_minutes,
      :max_students, :personal_deportivo_id, :court_type_id, :status
    )
  end

  def load_form_data
    @personal_deportivos = PersonalDeportivo.tipo_profesor
                                            .includes(:certificacion_archivo_attachment)
                                            .order(:apellido, :nombre)
                                            .select(&:certificacion_valida?)
    @court_types = CourtType.order(:name)
  end
end
