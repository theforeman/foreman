module Foreman::Controller::Parameters::HostBase
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::NicInterface
  include Foreman::Controller::Parameters::Parameter

  class_methods do
    def add_host_base_params_filter(filter)
      filter.permit :capabilities,
        :comment,
        :enabled,
        :ip,
        :ip6,
        :is_owned_by,
        :last_compile,
        :mac,
        :managed,
        :name,
        :overwrite,
        :provider,
        :root_pass,
        :start,
        :type,
        :pxe_loader,
        # Model relations sorted in alphabetical order
        :architecture, :architecture_id, :architecture_name,
        :domain, :domain_id, :domain_name,
        :environment, :environment_id, :environment_name,
        :hardware_model_id, :hardware_model_name,
        :hostgroup, :hostgroup_id, :hostgroup_name,
        :location, :location_id, :location_name,
        :medium, :medium_id, :medium_name,
        :model, :model_id, :model_name,
        :operatingsystem, :operatingsystem_id, :operatingsystem_name,
        :organization, :organization_id, :organization_name,
        :ptable, :ptable_id, :ptable_name,
        :progress_report, :progress_report_id, :progress_report_name,
        :realm, :realm_id, :realm_name,
        :subnet, :subnet_id, :subnet_name,
        :subnet6, :subnet6_id, :subnet6_name,
        :config_groups => [], :config_group_ids => [], :config_group_names => [],
        :host_parameters_attributes => [parameter_params_filter(HostParameter)],
        :interfaces => [nic_interface_params_filter], :interfaces_attributes => [nic_interface_params_filter],
        :puppetclasses => [], :puppetclass_ids => [], :puppetclass_names => []
    end
  end
end
