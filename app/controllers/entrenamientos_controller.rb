class EntrenamientosController < ApplicationController
  def index
    @entrenamientos = Entrenamiento.includes(:personal_deportivo)
                                   .where(status: :activo)
                                   .order(:scheduled_at)
    authorize @entrenamientos
  end

  def show
    @entrenamiento = Entrenamiento.find(params[:id])
    authorize @entrenamiento
    if current_user
      @my_asistencia = @entrenamiento.asistencias.find_by(user_id: current_user.id)
    end
  end
end
