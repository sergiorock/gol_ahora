class CourtsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @sizes    = CourtType.distinct.pluck(:name).uniq.sort_by { |n| n[/\d+/].to_i }
    @surfaces = CourtType.distinct.pluck(:surface).uniq.compact.sort

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
