class StaticPagesController < ApplicationController
  def home
    return unless logged_in?

    @micropost = current_user.microposts.build
    @pagy, @feed_items = pagy current_user.feed,
                              limit: Settings.default.pagination.microposts
  end

  def help; end
end
