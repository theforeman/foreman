require_dependency 'facets'

module Facets
  module BaseHostExtensions
    extend ActiveSupport::Concern
    include Facets::ModelExtensionsBase

    # This method will return attributes list augmented with attributes that are
    # set by the facet. Each registered facet will get opportunity to add its
    # own attributes to the list.
    def apply_facet_attributes(hostgroup, attributes)
      Facets.registered_facets(:host).values.map(&:host_configuration).map do |facet_config|
        facet_attributes = attributes["#{facet_config.name}_attributes"] || {}
        facet_attributes = facet_config.model.inherited_attributes(hostgroup, facet_attributes)
        attributes["#{facet_config.name}_attributes"] = facet_attributes unless facet_attributes.empty?
      end
      attributes
    end

    def populate_facet_fields(parser, type, source_proxy)
      Facets.registered_facets.values.each do |facet_config|
        facet_config.model.populate_fields_from_facts(self, parser, type, source_proxy)
      end
    end
  end
end
