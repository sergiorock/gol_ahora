class TournamentsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @tournaments = Tournament.order(start_date: :desc)
    authorize @tournaments
  end

  def show
    @tournament = Tournament.find(params[:id])
    @matches    = @tournament.matches.includes(:court).order(:played_at)
    authorize @tournament
  end
end
