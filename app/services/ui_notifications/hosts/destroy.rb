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
          subject: subject.owner, # note we store the host owner, as the host object is being deleted.
          message: StringParser.new(blueprint.message, {subject: subject}),
          notification_blueprint: blueprint
        )
      end

      def audience
        case subject.owner_type
        when 'User'
          ::Notification::AUDIENCE_USER
        when 'Usergroup'
          ::Notification::AUDIENCE_USERGROUP
        end
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
