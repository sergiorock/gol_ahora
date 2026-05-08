class Admin::TournamentsController < Admin::BaseController
  before_action :set_tournament, only: %i[show edit update destroy]

  def index
    authorize Tournament
    @current    = policy_scope(Tournament).current.order(:start_date)
    @historical = policy_scope(Tournament).historical.order(end_date: :desc)
  end

  def show
    authorize @tournament
    @matches = @tournament.matches.includes(:court).order(:played_at)
  end

  def new
    @tournament = Tournament.new
    authorize @tournament
  end

  def create
    @tournament = Tournament.new(tournament_params)
    authorize @tournament
    if @tournament.save
      redirect_to admin_tournament_path(@tournament), notice: "Torneo creado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @tournament
  end

  def update
    authorize @tournament
    if @tournament.update(tournament_params)
      redirect_to admin_tournament_path(@tournament), notice: "Torneo actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @tournament
    @tournament.destroy
    redirect_to admin_tournaments_path, notice: "Torneo eliminado."
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:id])
  end

  def tournament_params
    params.require(:tournament).permit(:name, :description, :format, :start_date, :end_date, :status, :rules)
  end
end
