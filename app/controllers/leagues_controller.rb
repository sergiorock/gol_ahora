class LeaguesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @leagues = League.order(start_date: :desc)
    authorize @leagues
  end

  def show
    @league  = League.find(params[:id])
    @matches = @league.matches.includes(:court).order(:played_at)
    authorize @league
  end
end
