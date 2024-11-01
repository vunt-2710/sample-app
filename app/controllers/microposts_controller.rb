class MicropostsController < ApplicationController
  before_action :logged_in_user?, only: %i(create destroy)
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.newest.build micropost_params
    @micropost.image.attach params.dig(:micropost, :image)
    if @micropost.save
      create_success
    else
      create_fail
    end
  end

  def destroy
    if @micropost.destroy
      flash[:success] = t "flash.micropost.deleteSuccess"
    else
      flash[:danger] = t "flash.micropost.deleteFail"
    end
    redirect_to request.referer || root_url
  end

  private

  def micropost_params
    params.require(:micropost).permit(Micropost::PERMITTED_PARAMS)
  end

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    return if @micropost

    flash[:danger] = t "flash.micropost.notYours"
    redirect_to request.referer || root_url
  end

  def create_success
    flash[:success] = t "flash.micropost.createSuccess"
    redirect_to root_url
  end

  def create_fail
    @pagy, @feed_items = pagy current_user.feed,
                              limits: Settings.default.pagination.microposts
    render "static_pages/home", status: :unprocessable_entity
  end
end
