module Foreman
  class Plugin
    class EventObserversRegistry
      delegate :logger, to: Rails
      attr_reader :event_observers

      def initialize
        @event_observers = []
      end

      def register_event_observer(klass)
        @event_observers << klass
      end

      def unregister_event_observer(klass)
        @event_observers.delete(klass)
      end
    end
  end
end
