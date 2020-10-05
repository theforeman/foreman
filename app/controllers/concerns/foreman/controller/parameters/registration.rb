module Foreman::Controller::Parameters::Registration
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::NicInterface
  include Foreman::Controller::Parameters::Parameter

  class_methods do
    def host_params_filter
      Foreman::ParameterFilter.new(::Host::Managed).tap do |filter|
        filter.permit :name,
          :location, :location_id, :location_name,
          :organization, :organization_id, :organization_name,
          :ip,
          :ip6,
          :mac,
          :domain, :domain_id, :domain_name,
          :operatingsystem, :operatingsystem_id, :operatingsystem_name,
          :subnet, :subnet_id, :subnet_name,
          :model, :model_id, :model_name,
          :hostgroup, :hostgroup_id, :hostgroup_name,
          :build,
          :enabled,
          :managed,
          :comment,
          :uuid,
          :owner,
          interfaces: [nic_interface_params_filter],
          interfaces_attributes: [nic_interface_params_filter],
          host_parameters_attributes: [parameter_params_filter(HostParameter)]

        facets = Facets.registered_facets.values.map { |facet_config| "#{facet_config.name}_attributes" }
        filter.permit(*facets) if facets.present?
      end
    end
  end

  def host_params(top_level_hash = controller_name.singularize)
    self.class.host_params_filter.filter_params(params, parameter_filter_context, top_level_hash)
  end
end
