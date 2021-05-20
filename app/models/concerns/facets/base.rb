require_dependency 'facets'

module Facets
  module Base
    extend ActiveSupport::Concern

    included do
      belongs_to_host
    end

    # Add facet's details to host's ENC by returning it from this method
    # Basic ENC hash structure:
    # ---
    # classes:
    #   ...
    # parameters:
    #   ...
    # environment:
    #   ...
    def info
      {}
    end

    # Specify any smart proxy id's used by this facet.
    def smart_proxy_ids
      []
    end

    # Add any filters to template selection returned from host
    def template_filter_options(kind)
      {}
    end

    # Add search criteria for finding a configuration template.
    def provisioning_template_options
      {}
    end

    module ClassMethods
      # Change attributes that will be sent to an facet based on inherited values from the hostgroup.
      def inherited_attributes(hostgroup, facet_attributes)
        _, facet_config = Facets.find_facet_by_class(self, :host)

        if facet_config.has_hostgroup_configuration? && hostgroup
          facet_attributes = hostgroup.inherited_facet_attributes(facet_config)
        end
        facet_attributes
      end

      # Use this method to populate host's fields based on fact values exposed by the importer.
      # You can populate fields in the associated host's facets too.
      def populate_fields_from_facts(host, parser, type, proxy)
      end
    end
  end
end
