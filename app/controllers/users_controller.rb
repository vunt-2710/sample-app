class UsersController < ApplicationController
  before_action :load_user, except: %i(index new create)
  before_action :logged_in_user?, except: %i(new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @pagy, @users = pagy User.all, limit: Settings.default.pagination.users
  end

  def show
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t "flash.warning"
    redirect_to root_path
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "flash.needActivation"
      redirect_to root_path, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:success] = t "flash.updateSuccess"
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "flash.deleteSuccess"
    else
      flash[:danger] = t "flash.deleteFail"
    end
    redirect_to users_path
  end

  private
  def user_params
    params.require(:user)
          .permit(User::PERMITTED_PARAMS)
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "flash.notFoundUser"
    redirect_to root_path
  end

  def logged_in_user?
    return if logged_in?

    store_location
    flash[:danger] = t "flash.notLoggedIn"
    redirect_to login_url
  end

  def correct_user
    return if current_user? @user

    flash[:danger] = t "flash.notYourAccount"
    redirect_to root_path
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end
end
