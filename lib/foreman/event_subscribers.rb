module Foreman
  module EventSubscribers
    def self.all_observable_events
      # in development descendants will only return classes if they have been loaded
      @all_observable_events ||= begin
        if Rails.env.development?
          Rails.logger.debug "Performing eager load to find out all observable classes"
          Rails.application.eager_load!
        end
        ApplicationRecord.descendants.select { |klass| klass <= ::Foreman::ObservableModel }.map(&:event_subscription_hooks) +
        ApplicationJob.descendants.select { |klass| klass <= ::Foreman::ObservableJob }.map(&:event_subscription_hooks) +
        Foreman::Plugin.all.map(&:observable_events)
      end.flatten.uniq
    end
  end
end
