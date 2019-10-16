module Foreman
  module EventSubscribers
    def self.all_observable_events
      ActiveRecord::Base.descendants.select { |klass| klass <= ::Foreman::EventSubscribers::Observable }.map(&:event_subscription_hooks).flatten.uniq
    end
  end
end
