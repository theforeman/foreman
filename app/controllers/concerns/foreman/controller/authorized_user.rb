module Foreman::Controller::AuthorizedUser
  extend ActiveSupport::Concern
  include Foreman::Controller::UserSelfEditing

  private

  def find_authorized_user(permission, user_id = nil)
    if editing_self? && (user_id.nil? || user_id.to_s == User.current.id.to_s)
      return @user = User.current
    end

    user_id ||= params[:user_id]
    @user = User.authorized(permission).except_hidden.find_by(:id => user_id)
  end

  def editing_self_params
    super.merge(:user_id => params[:user_id])
  end
end
