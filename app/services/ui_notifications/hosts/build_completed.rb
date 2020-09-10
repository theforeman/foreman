module UINotifications
  module Hosts
    class BuildCompleted < Base
      private

      def create
        add_notification if update_notifications.zero?
      end

      def add_notification
        ::Notification.create!(
          initiator: initiator,
          subject: subject,
          audience: audience,
          notification_blueprint: blueprint
        )
      end

      def update_notifications
        blueprint.notifications.
          where(subject: subject).
          update_all(expired_at: blueprint.expired_at)
      end

      def blueprint
        @blueprint ||= NotificationBlueprint.find_by(name: 'host_build_completed')
      end
    end
  end
end
