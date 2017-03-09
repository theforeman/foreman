module UINotifications
  module Hosts
    class Destroy < Base
      private

      def create
        # I'm defaulting to deleting older notifications as it may
        # contain links to non existing actions.
        delete_others
        Notification.create!(
          initiator: initiator,
          audience: audience,
          # note we do not store the subject, as the object is being deleted.
          message: StringParser.new(blueprint.message, {subject: subject}),
          notification_blueprint: blueprint
        )
      end

      def delete_others
        logger.debug("Removing all notifications for host: #{subject}")
        Notification.where(subject: subject).destroy_all
      end

      def blueprint
        @blueprint ||= NotificationBlueprint.find_by(name: 'host_destroyed')
      end
    end
  end
end
