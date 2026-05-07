class CourtsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @sizes    = CourtType.distinct.order(:name).pluck(:name)
    @surfaces = CourtType.distinct.order(:surface).pluck(:surface).compact

    @courts = Court.includes(:court_type).available.order(:name)
    @courts = @courts.joins(:court_type).where(court_types: { name: params[:size] })       if params[:size].present?
    @courts = @courts.joins(:court_type).where(court_types: { surface: params[:surface] }) if params[:surface].present?

    authorize @courts
  end

  def show
    @court = Court.includes(:court_type).find(params[:id])
    authorize @court
  end
end
