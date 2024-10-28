class PasswordResetsController < ApplicationController
  before_action :load_user,
                :valid_user,
                :check_expiration,
                only: %i(edit update)

  def new; end

  def edit; end

  def create
    @user = User.find_by email: params.dig(:password_reset, :email).downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "flash.sentResetToken"
      redirect_to root_url
    else
      flash.now[:danger] = t "flash.notFoundEmail"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @user.assign_attributes(user_params)

    if @user.save(context: :password_reset)
      handle_success
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(User::RESET_PASSWORD_PARAMS)
  end

  def load_user
    @user = User.find_by email: params[:email]
    return if @user

    flash[:danger] = t "flash.warning"
    redirect_to root_url
  end

  def valid_user
    return if @user.activated && @user.authenticated?(:reset, params[:id])

    flash[:danger] = t "flash.unactivatedUser"
    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_token_expired?

    flash[:danger] = t "flash.passwordResetTokenExpired"
    redirect_to new_password_reset_url
  end

  def handle_success
    log_in @user
    @user.update_column :reset_digest, nil
    flash[:success] = t "flash.resetPassSuccess"
    redirect_to @user
  end
end
