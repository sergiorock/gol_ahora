class EntrenamientosController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    @entrenamientos = Entrenamiento.includes(:personal_deportivo, personal_deportivo: { certificacion_archivo_attachment: :blob })
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
