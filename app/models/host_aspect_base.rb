class HostAspectBase < ActiveRecord::Base
  self.abstract_class = true

  def self.inherited(subclass)
    super
    subclass.class_eval do
      belongs_to_host
    end
  end

  def info
    {}
  end

  def smart_proxy_ids
    []
  end

  def after_clone
  end

  def template_filter_options(kind)
    {}
  end

  def provisioning_template_options(base_options)
    base_options
  end

  def self.inherited_attributes(hostgroup, aspect_attributes)
    aspect_attributes
  end

  def self.populate_fields_from_facts(host, importer, type, proxy_id)
  end
end
