module Foreman::Controller::UserAware
  extend ActiveSupport::Concern
  include Foreman::Controller::UserSelfEditing

  included do
    before_action :find_user
  end

  private

  def resource_scope(*args, &block)
    super.where(:user => @user)
  end

  def find_user
    if editing_self?
      @user = User.current
    else
      @user = User.find(params[:user_id])
    end
  end

  def editing_self_params
    super.merge(:user_id => params[:user_id])
  end
end
