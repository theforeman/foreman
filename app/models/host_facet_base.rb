class HostFacetBase < ActiveRecord::Base
  self.abstract_class = true

  def self.inherited(subclass)
    super
    subclass.class_eval do
      belongs_to_host
    end
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

  # This method will be called after a host with all its facets is cloned.
  def after_clone
  end

  # Add any filters to template selection returned from host
  def template_filter_options(kind)
    {}
  end

  # Add or change search criteria for finding a configuration template.
  def provisioning_template_options(base_options)
    base_options
  end

  # Change attributes that will be sent to an facet based on inherited values from the hostgroup.
  def self.inherited_attributes(hostgroup, facet_attributes)
    facet_attributes
  end

  # Use this method to populate host's fields based on fact values exposed by the importer.
  # You can populate fields in the associted host's facets too.
  def self.populate_fields_from_facts(host, importer, type, proxy_id)
  end
end
