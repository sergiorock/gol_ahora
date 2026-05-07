class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: %i[show edit update destroy pdf]

  def index
    @users = User.order(:last_name, :first_name)
    authorize @users
  end

  def show
    authorize @user
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user

    if @user.save
      redirect_to admin_user_path(@user), notice: "Usuario creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @user
  end

  def update
    authorize @user

    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "Usuario actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def pdf
    authorize @user
    pdf = UserPdf.new(@user)
    send_data pdf.render,
      filename: "usuario_#{@user.id}_#{@user.last_name.parameterize}.pdf",
      type: "application/pdf",
      disposition: "inline"
  end

  def destroy
    authorize @user
    @user.destroy
    redirect_to admin_users_path, notice: "Usuario eliminado correctamente."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :role,
      :first_name, :last_name, :dni, :birth_date, :phone,
      :address, :postal_code, :country, :city, :joined_at
    )
  end
end
