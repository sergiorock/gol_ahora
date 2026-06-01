class Admin::PersonalDeportivosController < Admin::BaseController
  before_action :set_personal_deportivo, only: %i[show edit update destroy]

  def index
    @personal_deportivos = PersonalDeportivo.all.order(:apellido, :nombre)
    authorize @personal_deportivos
  end

  def show
    authorize @personal_deportivo
  end

  def new
    @personal_deportivo = PersonalDeportivo.new
    authorize @personal_deportivo
  end

  def create
    @personal_deportivo = PersonalDeportivo.new(personal_deportivo_params)
    authorize @personal_deportivo
    if @personal_deportivo.save
      redirect_to admin_personal_deportivo_path(@personal_deportivo), notice: "Personal deportivo creado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @personal_deportivo
  end

  def update
    authorize @personal_deportivo
    if @personal_deportivo.update(personal_deportivo_params)
      redirect_to admin_personal_deportivo_path(@personal_deportivo), notice: "Personal deportivo actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @personal_deportivo
    @personal_deportivo.destroy
    redirect_to admin_personal_deportivos_path, notice: "Personal deportivo eliminado."
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to admin_personal_deportivos_path, alert: "No se puede eliminar: tiene clases o entrenamientos asignados."
  end

  private

  def set_personal_deportivo
    @personal_deportivo = PersonalDeportivo.find(params[:id])
  end

  def personal_deportivo_params
    params.require(:personal_deportivo).permit(
      :nombre, :apellido, :email, :telefono, :tipo,
      :certificacion_deportiva, :fecha_certificacion, :observaciones,
      :certificacion_archivo
    )
  end
end
