class ClasesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    @clases = Clase.includes(:personal_deportivo, :court_type, personal_deportivo: { certificacion_archivo_attachment: :blob })
                   .where(status: :activa)
                   .order(:scheduled_at)
    authorize @clases
  end

  def show
    @clase = Clase.find(params[:id])
    authorize @clase
    if current_user
      @my_asistencia = @clase.asistencias.find_by(user_id: current_user.id)
    end
  end
end
