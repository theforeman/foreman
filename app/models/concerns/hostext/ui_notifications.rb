module Hostext
  module UINotifications
    def self.prepended(base)
      base.before_destroy :remove_ui_notifications
    end

    # Extend #built to deliver notification only when the build was successful
    def built(installed = true)
      super.tap do |result|
        ::UINotifications::Hosts::BuildCompleted.deliver!(self) if result && installed
      end
    end

    def remove_ui_notifications
      ::UINotifications::Hosts::Destroy.deliver!(self)
      true
    end
  end
end
