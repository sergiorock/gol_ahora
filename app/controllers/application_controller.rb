class ApplicationController < ActionController::Base
  include Pundit::Authorization

  allow_browser versions: :modern

  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError, with: :usuario_no_autorizado

  private

  def usuario_no_autorizado
    flash[:alert] = "No tenés permisos para realizar esta acción."
    redirect_back_or_to root_path
  end
end
