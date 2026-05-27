class Admin::EntrenamientosController < Admin::BaseController
  before_action :set_entrenamiento, only: %i[show edit update destroy]

  def index
    @entrenamientos = Entrenamiento.includes(:personal_deportivo).order(:scheduled_at)
    authorize @entrenamientos
  end

  def show
    authorize @entrenamiento
    @asistencias = @entrenamiento.asistencias.includes(:user).order("users.last_name")
  end

  def new
    @entrenamiento = Entrenamiento.new
    authorize @entrenamiento
    load_form_data
  end

  def create
    @entrenamiento = Entrenamiento.new(entrenamiento_params)
    authorize @entrenamiento
    if @entrenamiento.save
      repeat = params[:repeat_weeks].to_i
      if repeat > 1
        (1...repeat).each do |i|
          Entrenamiento.create!(entrenamiento_params.merge(scheduled_at: @entrenamiento.scheduled_at + i.weeks))
        end
      end
      semanas_msg = repeat > 1 ? " (#{repeat} sesiones generadas)" : ""
      redirect_to admin_entrenamientos_path, notice: "Entrenamiento creado#{semanas_msg}."
    else
      load_form_data
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @entrenamiento
    load_form_data
  end

  def update
    authorize @entrenamiento
    if @entrenamiento.update(entrenamiento_params)
      redirect_to admin_entrenamiento_path(@entrenamiento), notice: "Entrenamiento actualizado."
    else
      load_form_data
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @entrenamiento
    @entrenamiento.destroy
    redirect_to admin_entrenamientos_path, notice: "Entrenamiento eliminado."
  end

  private

  def set_entrenamiento
    @entrenamiento = Entrenamiento.find(params[:id])
  end

  def entrenamiento_params
    params.require(:entrenamiento).permit(
      :nombre, :descripcion, :scheduled_at, :duration_minutes,
      :max_students, :personal_deportivo_id, :status
    )
  end

  def load_form_data
    @personal_deportivos = PersonalDeportivo.where(tipo: :entrenador).order(:apellido, :nombre)
  end
end
