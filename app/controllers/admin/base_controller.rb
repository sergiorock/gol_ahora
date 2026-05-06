class Admin::BaseController < ApplicationController
  layout "admin"

  before_action :verificar_admin

  private

  def verificar_admin
    redirect_to root_path, alert: "Acceso restringido." unless current_user&.admin?
  end
end
