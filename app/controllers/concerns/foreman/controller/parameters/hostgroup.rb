module Foreman::Controller::Parameters::Hostgroup
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::HostCommon
  include Foreman::Controller::Parameters::NestedAncestryCommon
  include Foreman::Controller::Parameters::Parameter
  include Foreman::Controller::Parameters::Taxonomix

  class_methods do
    def hostgroup_params_filter
      Foreman::ParameterFilter.new(::Hostgroup).tap do |filter|
        filter.permit :name,
          :description,
          :root_pass,
          :title,
          :vm_defaults,
          :pxe_loader,
          # Relations in alphabetical order
          :arch, :arch_id, :arch_name,
          :architecture_id, :architecture_name,
          :compute_resource_id, :domain_id, :domain_name,
          :environment_id, :environment_name,
          :medium_id, :medium_name,
          :subnet_id, :subnet_name,
          :subnet6_id, :subnet6_name,
          :realm_id, :realm_name,
          :operatingsystem_id, :operatingsystem_name,
          :os, :os_id, :os_name,
          :ptable_id, :ptable_name,
          :config_group_names => [], :config_group_ids => [],
          :puppetclass_ids => [], :puppetclass_names => [],
          :group_parameters_attributes => [parameter_params_filter(::GroupParameter)]

        add_host_common_params_filter(filter)
        add_nested_ancestry_common_params_filter(filter)
        add_taxonomix_params_filter(filter)
      end
    end
  end

  def hostgroup_params(top_level_hash = controller_name.singularize)
    self.class.hostgroup_params_filter.filter_params(params, parameter_filter_context, top_level_hash)
  end
end
