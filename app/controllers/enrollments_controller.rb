class EnrollmentsController < ApplicationController
  before_action :set_enrollment, only: %i[destroy]
  before_action :verificar_cliente, only: %i[create]

  def index
    @enrollments = policy_scope(Enrollment).includes(:enrollable).order(enrolled_at: :desc)
    authorize @enrollments
    @asistencias = current_user.asistencias.includes(:asistible).order(attended_on: :desc)
  end

  def create
    competition = find_competition
    @enrollment = competition.enrollments.new(
      user:        current_user,
      team_name:   params[:enrollment][:team_name],
      enrolled_at: Time.current
    )
    authorize @enrollment

    if @enrollment.save
      redirect_back_or_to root_path, notice: "¡Inscripción registrada! Equipo: #{@enrollment.team_name}"
    else
      redirect_back_or_to root_path, alert: @enrollment.errors.full_messages.to_sentence
    end
  end

  def destroy
    authorize @enrollment
    @enrollment.update!(status: :cancelled)
    redirect_to enrollments_path, notice: "Inscripción cancelada."
  end

  private

  def set_enrollment
    @enrollment = current_user.enrollments.find(params[:id])
  end

  def verificar_cliente
    redirect_to root_path, alert: "Usá el panel de administración para inscribir equipos." if current_user.admin?
  end

  def find_competition
    if params[:league_id]
      League.find(params[:league_id])
    else
      Tournament.find(params[:tournament_id])
    end
  end
end
