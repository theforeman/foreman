module Foreman
  module ObservableJob
    extend ActiveSupport::Concern
    include Foreman::Observable

    included do
      class_attribute :event_subscription_hooks
      self.event_subscription_hooks ||= []
    end

    class_methods do
      def set_hook(hook_name, namespace: Foreman::Observable::DEFAULT_NAMESPACE, payload: nil, &blk)
        event_name = Foreman::Observable.event_name_for(hook_name, namespace: namespace)
        self.event_subscription_hooks |= [event_name]

        after_perform do |job|
          trigger_hook hook_name, namespace: namespace, payload: payload, block_argument: job.serialize, &blk
        end
        nil
      end
    end

    def event_payload_for(payload, block_argument, blk)
      super || block_argument
    end
  end
end
