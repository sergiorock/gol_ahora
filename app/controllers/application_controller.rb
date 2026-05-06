class ApplicationController < ActionController::Base
  include Pundit::Authorization

  allow_browser versions: :modern

  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError, with: :usuario_no_autorizado

  private

  def after_sign_in_path_for(resource)
    resource.admin? ? admin_root_path : root_path
  end

  def after_sign_out_path_for(_resource)
    root_path
  end

  def usuario_no_autorizado
    flash[:alert] = "No tenés permisos para realizar esta acción."
    redirect_back_or_to root_path
  end
end
