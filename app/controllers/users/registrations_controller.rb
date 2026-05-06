class Users::RegistrationsController < Devise::RegistrationsController
  private

  def sign_up_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      :nombres, :apellido, :dni, :edad, :telefono,
      :domicilio, :codigo_postal, :pais, :localidad
    )
  end

  def account_update_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :current_password,
      :nombres, :apellido, :dni, :edad, :telefono,
      :domicilio, :codigo_postal, :pais, :localidad
    )
  end
end
