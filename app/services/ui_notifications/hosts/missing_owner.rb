module UINotifications
  module Hosts
    class MissingOwner < UINotifications::Base
      private

      def create
        add_notification if update_notifications.zero?
      end

      def update_notifications
        blueprint.notifications.
          where(subject: subject).
          update_all(expired_at: blueprint.expired_at)
      end

      def add_notification
        Notification.create!(
          initiator: initiator,
          audience: ::Notification::AUDIENCE_ADMIN,
          subject: subject,
          notification_blueprint: blueprint
        )
      end

      def blueprint
        @blueprint ||= NotificationBlueprint.find_by(name: 'host_missing_owner')
      end
    end
  end
end
