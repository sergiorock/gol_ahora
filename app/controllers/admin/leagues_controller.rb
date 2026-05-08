class Admin::LeaguesController < Admin::BaseController
  before_action :set_league, only: %i[show edit update destroy]

  def index
    authorize League
    @current    = policy_scope(League).current.order(:start_date)
    @historical = policy_scope(League).historical.order(end_date: :desc)
  end

  def show
    authorize @league
    @matches = @league.matches.includes(:court).order(:played_at)
  end

  def new
    @league = League.new
    authorize @league
  end

  def create
    @league = League.new(league_params)
    authorize @league
    if @league.save
      redirect_to admin_league_path(@league), notice: "Liga creada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @league
  end

  def update
    authorize @league
    if @league.update(league_params)
      redirect_to admin_league_path(@league), notice: "Liga actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @league
    @league.destroy
    redirect_to admin_leagues_path, notice: "Liga eliminada."
  end

  private

  def set_league
    @league = League.find(params[:id])
  end

  def league_params
    params.require(:league).permit(:name, :description, :start_date, :end_date, :status, :rules)
  end
end
