class CourtsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @court_types = CourtType.order(:name)
    @courts = Court.includes(:court_type).available.order(:name)
    @courts = @courts.where(court_type_id: params[:type]) if params[:type].present?
    authorize @courts
  end

  def show
    @court = Court.includes(:court_type).find(params[:id])
    authorize @court
  end
end
