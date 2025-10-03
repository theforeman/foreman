module Foreman
  class Plugin
    class AppMetadataRegistry
      def initialize
        @plugin_metadata = {}.with_indifferent_access
      end

      def register(plugin_name, data = {})
        unless data.is_a?(Hash) || data.respond_to?(:to_h)
          Rails.logger.warn "AppMetadataRegistry: data for plugin #{plugin_name} is not a hash or compatible type; registration skipped."
          return
        end
        @plugin_metadata[plugin_name] = data.is_a?(Hash) ? data : data.to_h
        Rails.logger.info "Registered app metadata for plugin #{plugin_name}"
      end

      def all_plugin_metadata
        @plugin_metadata
      end
    end
  end
end
