class ProfilesController < ApplicationController
  def show
  end

  def edit
  end

  def update
    if current_user.update(profile_params)
      redirect_to profile_path, notice: "Perfil actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(
      :first_name, :last_name, :dni, :birth_date, :phone,
      :address, :postal_code, :city, :province, :country
    )
  end
end
