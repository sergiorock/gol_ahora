class Admin::AsistenciasController < Admin::BaseController
  before_action :set_parent
  before_action :set_asistencia, only: %i[update destroy]

  def create
    @asistencia = @parent.asistencias.new(asistencia_params)
    authorize @asistencia
    if @asistencia.save
      redirect_to parent_admin_path, notice: "Inscripción registrada."
    else
      redirect_to parent_admin_path, alert: @asistencia.errors.full_messages.to_sentence
    end
  end

  def update
    authorize @asistencia
    @asistencia.update(present: params[:present] == "true")
    redirect_to parent_admin_path, notice: "Asistencia actualizada."
  end

  def destroy
    authorize @asistencia
    @asistencia.destroy
    redirect_to parent_admin_path, notice: "Inscripción eliminada."
  end

  private

  def set_parent
    if params[:clase_id]
      @parent = Clase.find(params[:clase_id])
      @parent_type = :clase
    elsif params[:entrenamiento_id]
      @parent = Entrenamiento.find(params[:entrenamiento_id])
      @parent_type = :entrenamiento
    end
  end

  def set_asistencia
    @asistencia = @parent.asistencias.find(params[:id])
  end

  def asistencia_params
    params.require(:asistencia).permit(:user_id, :attended_on, :present)
  end

  def parent_admin_path
    if @parent_type == :clase
      admin_clase_path(@parent)
    else
      admin_entrenamiento_path(@parent)
    end
  end
end
