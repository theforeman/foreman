module Foreman::Controller::UserSelfEditing
  extend ActiveSupport::Concern

  protected

  def editing_self?
    @editing_self ||= User.current.editing_self?(editing_self_params)
  end

  def editing_self_params
    params.slice(:controller, :action, :id)
  end
end
