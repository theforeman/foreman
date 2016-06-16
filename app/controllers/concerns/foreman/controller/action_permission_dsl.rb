module Foreman::Controller::ActionPermissionDsl
  extend ActiveSupport::Concern

  included do |klass|
    klass.class_attribute :action_permissions
  end

  module ClassMethods
    def define_action_permission(actions, permission)
      self.action_permissions ||= {}
      # for single action case
      [actions].flatten.each do |action|
        self.action_permissions[action] = permission
      end
    end
  end

  def action_permission
    action_permissions[params[:action]] || super
  end
end
