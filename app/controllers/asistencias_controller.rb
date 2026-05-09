class AsistenciasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_parent

  def create
    @asistencia = @parent.asistencias.new(
      user: current_user,
      attended_on: @parent.scheduled_at&.to_date || Date.today,
      present: false
    )
    authorize @asistencia

    if @asistencia.save
      redirect_to parent_path, notice: "Te inscribiste correctamente."
    else
      redirect_to parent_path, alert: @asistencia.errors.full_messages.to_sentence
    end
  end

  def destroy
    @asistencia = @parent.asistencias.find(params[:id])
    authorize @asistencia
    @asistencia.destroy
    redirect_to parent_path, notice: "Inscripción cancelada."
  end

  private

  def set_parent
    if params[:clase_id]
      @parent = Clase.find(params[:clase_id])
    elsif params[:entrenamiento_id]
      @parent = Entrenamiento.find(params[:entrenamiento_id])
    end
  end

  def parent_path
    if @parent.is_a?(Clase)
      clase_path(@parent)
    else
      entrenamiento_path(@parent)
    end
  end
end
