require 'facets'

module Facets
  module ManagedHostExtensions
    extend ActiveSupport::Concern

    included do
      Facets::ManagedHostExtensions.refresh_facet_relations(self)
      after_save :clear_association_cache #should be removed after moving to rails 4. Fixes an issue with save! that breaks :inverse_of.

      def attributes
        hash = super

        # include all facet attributes by default
        host_facets_with_definitions.each do |facet, facet_definition|
          hash["#{facet_definition.name}_attributes"] = facet.attributes.reject { |key, _| %w(created_at updated_at).include? key }
        end
        hash
      end
    end

    def self.refresh_facet_relations(klass)
      Facets.configuration.registered_facets.values.each do |facet_config|
        self.register_facet_relation(klass, facet_config)
      end
    end

    def self.register_facet_relation(klass, facet_config)
      klass.class_eval do
        has_one facet_config.name, :class_name => facet_config.model_class.name, :foreign_key => :host_id, :inverse_of => :host
        accepts_nested_attributes_for facet_config.name

        include facet_config.extension_class if facet_config.extension

        include_in_clone facet_config.name
      end
    end

    def host_facets
      host_facets_with_definitions.keys
    end

    def host_facets_with_definitions
      Hash[(Facets.configuration.registered_facets.values.map do |facet_config|
        facet = send(facet_config.name)
        [facet, facet_config] if facet
      end).compact]
    end
  end
end
