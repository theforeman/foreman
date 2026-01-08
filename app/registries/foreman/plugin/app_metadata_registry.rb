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

      def all_plugin_metadata_resolved
        @plugin_metadata.transform_values { |v| self.class.resolve_procs(v) }
      end

      # Evaluates any Proc values in the given hash, calling them and replacing
      # them with their return values. All other values remain unchanged.
      # @param hash [Hash] A hash potentially containing Proc values
      # @return [Hash] A new hash with Procs evaluated
      def self.resolve_procs(hash)
        hash.transform_values { |v| v.is_a?(Proc) ? v.call : v }
      end
    end
  end
end
