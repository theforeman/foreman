module HostFacets
  class Base < ActiveRecord::Base
    self.abstract_class = true

    belongs_to_host

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

    # Change attributes that will be sent to an facet based on inherited values from the hostgroup.
    def self.inherited_attributes(hostgroup, facet_attributes)
      facet_attributes
    end

    # Use this method to populate host's fields based on fact values exposed by the importer.
    # You can populate fields in the associated host's facets too.
    def self.populate_fields_from_facts(host, importer, type, proxy_id)
    end
  end
end
