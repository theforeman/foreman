module Foreman::Controller::Parameters::Taxonomy
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::NestedAncestryCommon

  class_methods do
    def add_taxonomy_params_filter(filter)
      filter.permit :description,
        :name,
        :title,
        :compute_resource_ids => [], :compute_resource_names => [],
        :domain_ids => [], :domain_names => [],
        :environment_ids => [], :environment_names => [],
        :hostgroup_ids => [], :hostgroup_names => [],
        :ignore_types => [],
        :location_ids => [], :location_names => [],
        :medium_ids => [], :medium_names => [],
        :organization_ids => [], :organization_names => [],
        :provisioning_template_ids => [], :provisioning_template_names => [],
        :ptable_ids => [], :ptable_names => [],
        :realm_ids => [], :realm_names => [],
        :smart_proxy_ids => [], :smart_proxy_names => [],
        :subnet_ids => [], :subnet_names => [],
        :user_ids => [], :users => [], :user_names => []
      add_nested_ancestry_common_params_filter(filter)
    end
  end
end
