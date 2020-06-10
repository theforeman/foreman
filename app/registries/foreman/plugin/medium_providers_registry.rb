module Foreman
  class Plugin
    # This class is used to store list of medium uri providers that are responsible to supply
    # locations of installation medium in form of URI.
    # This is used by provisioning framework to supply download location for various files
    # used during the provisioning.
    class MediumProvidersRegistry
      delegate :logger, to: Rails
      attr_reader :providers

      def initialize
        @providers = []
      end

      # Register a new medium_uri provider.
      def register(provider)
        provider = provider.to_s
        @providers.unshift(provider)
        provider
      end

      def unregister(provider)
        @providers.delete(provider.to_s)
      end

      # Find a provider that can provide a URI for a given entity.
      def find_provider(entity)
        raise Foreman::Exception.new('Must supply an entity to find a medium provider') unless entity

        provider_instances = providers.map { |provider| provider.constantize.new(entity) }
        valid_providers = provider_instances.select { |provider| provider.valid? }
        if valid_providers.count > 1
          logger.error(
            'Found more than one provider for %{entity}. Found: %{found}. Valid providers: %{providers}' %
            {
              entity: entity,
              providers: providers.map { |provider| provider.class.name },
              found: valid_providers.map { |provider| provider.class.name },
            })
        end

        unless valid_providers.present?
          logger.warn(
            'Could not find a provider for %{entity}. Providers returned %{errors}' %
            {
              entity: entity,
              errors: provider_instances.map { |provider| [provider.class.name, provider.errors] }.to_h,
            })
        end

        valid_providers.first
      end

      private

      def ensure_provider(selected_provider, entity)
        return if selected_provider.present?

        self.class.providers.reduce({}) do |errors_hash, provider|
          errors_hash[provider.friendly_name] = provider.errors(entity)
        end
      end
    end
  end
end
