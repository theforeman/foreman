module Foreman
  module Observable
    DEFAULT_NAMESPACE = 'event.foreman'

    def trigger_hook(hook_name, namespace: DEFAULT_NAMESPACE, payload: nil, block_argument: self, &blk)
      event_name = event_name_for(hook_name, namespace: namespace)
      event_payload = { context: ::Logging.mdc.context.symbolize_keys }.with_indifferent_access
      yielded_payload = event_payload_for(payload, block_argument, blk)
      event_payload.merge!(yielded_payload) if yielded_payload
      ActiveSupport::Notifications.instrument(event_name, event_payload)
    end

    private

    def event_name_for(hook_name, namespace: DEFAULT_NAMESPACE)
      [hook_name.to_s.tr('/', '.'), namespace].compact.join('.')
    end
    module_function :event_name_for

    def event_payload_for(payload, block_argument, blk)
      payload || blk&.call(block_argument)&.to_h
    end
  end
end
