module Foreman
  module ObservableModel
    extend ActiveSupport::Concern
    include Foreman::Observable

    included do
      attr_reader :preloaded_object

      class_attribute :event_subscription_hooks
      self.event_subscription_hooks ||= []
    end

    class_methods do
      def set_hook(hook_name, namespace: Foreman::Observable::DEFAULT_NAMESPACE, payload: nil, **options, &blk)
        event_name = Foreman::Observable.event_name_for(hook_name, namespace: namespace)
        self.event_subscription_hooks |= [event_name]

        before_destroy :preload_object, prepend: true

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
          set_hook hook_name, namespace: namespace, on: k, payload: payload, **options, &blk
        end
      end

      def register_custom_hook(hook_name, namespace: Foreman::Observable::DEFAULT_NAMESPACE)
        event_name = Foreman::Observable.event_name_for(hook_name, namespace: namespace)
        self.event_subscription_hooks |= [event_name]
      end

      def preload_scopes_builder
        @preload_scopes_builder ||= Foreman::PreloadScopesBuilder.new(self)
      end
    end

    def event_payload_for(payload, block_argument, blk)
      super || { object: preloaded_object || self }
    end

    def preload_object
      @preloaded_object = self.class.includes(self.class.preload_scopes_builder.scopes).find(id)
    rescue => e
      Rails.logger.error("Could not find a #{self.class} with id #{id}")
      Rails.logger.error(e.full_message)
      nil
    end

    def anonymous_admin_context?
      [
        ::User::ANONYMOUS_ADMIN, ::User::ANONYMOUS_API_ADMIN, ::User::ANONYMOUS_CONSOLE_ADMIN
      ].include?(::Logging.mdc.context['user_login'])
    end
  end
end
