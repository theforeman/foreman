module Foreman::Controller::SetRedirectionPath
  extend ActiveSupport::Concern

  included do
    before_action :set_redirect_path, only: [:new, :edit, :destroy]
    after_action :reset_redirect_path, only: [:create, :update, :destroy]
  end

  private

  def reset_redirect_path
    session[:redirect_path] = nil
  end

  def set_redirect_path
    # Clear the stored url if the referer is the current URL. This can occur due
    # to client side routing that modifies the history prior to the page load.
    return reset_redirect_path if request.url == request.referer
    session[:redirect_path] = request.referer
  end
end
