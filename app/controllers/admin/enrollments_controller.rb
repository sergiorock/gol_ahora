class Admin::EnrollmentsController < Admin::BaseController
  before_action :set_competition
  before_action :set_enrollment, only: %i[edit update destroy]

  def index
    authorize Enrollment
    @enrollments = @competition.enrollments.includes(:user).order(:team_name)
  end

  def new
    @enrollment = @competition.enrollments.new
    authorize @enrollment
    @users = User.where(role: :client).order(:last_name, :first_name)
  end

  def create
    @enrollment = @competition.enrollments.new(enrollment_params)
    authorize @enrollment
    if @enrollment.save
      redirect_to competition_path, notice: "Inscripción registrada."
    else
      @users = User.where(role: :client).order(:last_name, :first_name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @enrollment
    @users = User.where(role: :client).order(:last_name, :first_name)
  end

  def update
    authorize @enrollment
    if @enrollment.update(enrollment_params)
      redirect_to competition_path, notice: "Inscripción actualizada."
    else
      @users = User.where(role: :client).order(:last_name, :first_name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @enrollment
    @enrollment.destroy
    redirect_to competition_path, notice: "Inscripción eliminada."
  end

  private

  def set_competition
    if params[:league_id]
      @competition      = League.find(params[:league_id])
      @competition_type = :league
    else
      @competition      = Tournament.find(params[:tournament_id])
      @competition_type = :tournament
    end
  end

  def set_enrollment
    @enrollment = @competition.enrollments.find(params[:id])
  end

  def competition_path
    @competition_type == :league ? admin_league_path(@competition) : admin_tournament_path(@competition)
  end

  def enrollment_params
    params.require(:enrollment).permit(:user_id, :team_name, :status)
  end
end
