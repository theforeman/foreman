module Foreman
  module ObservableModel
    extend ActiveSupport::Concern
    include Foreman::Observable

    included do
      class_attribute :event_subscription_hooks
      self.event_subscription_hooks ||= []
    end

    class_methods do
      def set_hook(hook_name, namespace: Foreman::Observable::DEFAULT_NAMESPACE, payload: nil, **options, &blk)
        event_name = Foreman::Observable.event_name_for(hook_name, namespace: namespace)
        self.event_subscription_hooks |= [event_name]

        after_commit(**options) do
          trigger_hook hook_name, namespace: namespace, payload: payload, &blk
        end
        nil
      end

      def set_crud_hooks(model_name, namespace: Foreman::Observable::DEFAULT_NAMESPACE, payload: nil, **options, &blk)
        {
          create: :created,
          update: :updated,
          destroy: :destroyed,
        }.each do |k, v|
          hook_name = "#{model_name}_#{v}".to_sym
          set_hook hook_name, namespace: namespace, on: k, payload: payload, &blk
        end
      end
    end

    def event_payload_for(payload, blk)
      super || { object: self }
    end
  end
end
