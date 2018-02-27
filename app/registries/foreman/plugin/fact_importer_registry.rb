module Foreman
  class Plugin
    class FactImporterRegistry
      attr_accessor :importers

      def initialize
        @importers = {}.with_indifferent_access
      end

      def register(key, klass, default = false)
        @importers.default = klass.to_s if default
        @importers[key.to_sym] = klass.to_s
      end

      def get(key)
        @importers[key].constantize
      end

      def fact_features
        @importers.values.map { |importer| importer.constantize.authorized_smart_proxy_features }.compact.flatten.uniq
      end
    end
  end
end
