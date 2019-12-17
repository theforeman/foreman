module Foreman
  module Observable
    DEFAULT_NAMESPACE = 'event.foreman'

    def trigger_hook(hook_name, namespace: DEFAULT_NAMESPACE, payload: nil, &blk)
      event_name = event_name_for(hook_name, namespace: namespace)
      event_context = { context: ::Logging.mdc.context.symbolize_keys }
      event_payload = event_payload_for(payload, blk).to_h
      payload_with_context = event_payload.merge(event_context)
      ActiveSupport::Notifications.instrument(event_name, payload_with_context)
    end

    private

    def event_name_for(hook_name, namespace: DEFAULT_NAMESPACE)
      [hook_name, namespace].compact.join('.')
    end
    module_function :event_name_for

    def event_payload_for(payload, blk)
      payload || blk&.call(self)
    end
  end
end
