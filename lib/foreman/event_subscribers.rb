module Foreman
  module EventSubscribers
    def self.all_observable_events
      # in development descendants will only return classes if they have been loaded
      @all_observable_events ||= ActiveRecord::Base.descendants.select { |klass| klass <= ::Foreman::ObservableModel }.map(&:event_subscription_hooks).flatten.uniq
    end
  end
end
