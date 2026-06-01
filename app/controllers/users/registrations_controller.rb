class Users::RegistrationsController < Devise::RegistrationsController
  private

  def sign_up_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      :first_name, :last_name, :dni, :birth_date, :phone,
      :address, :postal_code, :country, :city, :province
    )
  end

  def account_update_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :current_password,
      :first_name, :last_name, :dni, :birth_date, :phone,
      :address, :postal_code, :country, :city, :province
    )
  end
end
