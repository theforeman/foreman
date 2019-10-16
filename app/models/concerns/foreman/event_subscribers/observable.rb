module Foreman
  module EventSubscribers
    module Observable
      extend ActiveSupport::Concern

      included do
        class_attribute :event_subscription_hooks
        self.event_subscription_hooks ||= []
      end

      module ClassMethods
        def notify_event_observers(on:, with:, payload: nil, &blk)
          event_name = "#{event_subscription_namespace}_#{with}"
          self.event_subscription_hooks |= [event_name]
          after_commit on: on do
            actual_payload = blk&.call(self) || payload || { id: id }
            do_notify_event_observers(with, payload: actual_payload)
          end
        end

        def event_subscription_namespace
          name.underscore
        end
      end

      private

      def do_notify_event_observers(action, payload:)
        event_name = "#{self.class.event_subscription_namespace}_#{action}"
        Foreman::Plugin.all.map(&:event_observers).flatten.uniq.compact.map(&:constantize).each do |observer|
          observer.new.notify(event_name: event_name, payload: payload)
        end
      end
    end
  end
end
