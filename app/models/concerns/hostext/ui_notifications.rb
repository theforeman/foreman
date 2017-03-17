module Hostext
  module UINotifications
    extend ActiveSupport::Concern
    included do
      before_provision :provision_notification
      before_destroy :remove_ui_notifications
    end

    def provision_notification
      ::UINotifications::Hosts::BuildCompleted.deliver!(self) if just_provisioned?
      true
    end

    def remove_ui_notifications
      ::UINotifications::Hosts::Destroy.deliver!(self)
      true
    end

    def just_provisioned?
      !!previous_changes['installed_at']
    end
  end
end
