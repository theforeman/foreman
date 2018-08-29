require 'facets'

module Facets
  module ManagedHostExtensions
    extend ActiveSupport::Concern

    included do
      include Facets::BaseHostExtensions
      Facets::ManagedHostExtensions.refresh_facet_relations(self)
    end

    class << self
      def refresh_facet_relations(klass)
        Facets.registered_facets.values.each do |facet_config|
          self.register_facet_relation(klass, facet_config)
        end
      end

      # This method is used to add all relation objects necessary for accessing facet from the host object.
      # It:
      # 1. Includes facet in host's cloning mechanism
      def register_facet_relation(klass, facet_config)
        Facets::BaseHostExtensions.register_facet_relation(klass, facet_config)

        klass.class_eval do
          include_in_clone facet_config.name
        end
      end
    end
  end
end
