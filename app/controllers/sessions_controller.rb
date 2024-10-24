class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params.dig(:session, :email)&.downcase
    if user&.authenticate params.dig(:session, :password)
      handle_success(user)
    else
      handle_fail
    end
  end

  def destroy
    log_out
    redirect_to root_path, status: :see_other
  end

  def handle_success user
    reset_session
    log_in user
    params.dig(:session, :remember_me) == "1" ? remember(user) : forget(user)
    redirect_to user, status: :see_other
    flash[:success] = t "flash.loginSuccess"
  end

  def handle_fail
    flash.now[:danger] = t "views.signIn.error.wrongCredentials"
    render :new, status: :unprocessable_entity
  end
end
