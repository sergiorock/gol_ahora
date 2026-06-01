class Admin::MatchesController < Admin::BaseController
  before_action :set_competition
  before_action :set_match, only: %i[edit update destroy]

  def new
    @match = @competition.matches.new
    authorize @match
    load_form_data
  end

  def create
    @match = @competition.matches.new(match_params)
    authorize @match
    if @match.save
      redirect_to competition_path, notice: "Partido agregado."
    else
      load_form_data
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @match
    load_form_data
  end

  def update
    authorize @match
    if @match.update(match_params)
      redirect_to competition_path, notice: "Partido actualizado."
    else
      load_form_data
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @match
    @match.destroy
    redirect_to competition_path, notice: "Partido eliminado."
  end

  private

  def set_competition
    if params[:league_id]
      @competition = League.find(params[:league_id])
      @competition_type = :league
    else
      @competition = Tournament.find(params[:tournament_id])
      @competition_type = :tournament
    end
  end

  def set_match
    @match = @competition.matches.find(params[:id])
  end

  def load_form_data
    @courts = Court.available.includes(:court_type).order(:name)
    @teams  = @competition.enrollments.active.order(:team_name).pluck(:team_name)
  end

  def competition_path
    @competition_type == :league ? admin_league_path(@competition) : admin_tournament_path(@competition)
  end

  def match_params
    params.require(:match).permit(:home_team, :away_team, :home_goals, :away_goals,
                                  :played_at, :court_id, :official_rules)
  end
end
