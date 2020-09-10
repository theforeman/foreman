module Foreman::Controller::Parameters::Host
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::HostBase
  include Foreman::Controller::Parameters::HostCommon
  include Foreman::Controller::NormalizeScsiAttributes

  class_methods do
    def host_params_filter
      Foreman::ParameterFilter.new(::Host::Managed).tap do |filter|
        filter.permit :build,
          :certname,
          :disk,
          :global_status,
          :installed_at,
          :last_report,
          :otp,
          :provision_method,
          :uuid,
          :compute_profile_id, :compute_profile_name,
          :compute_resource, :compute_resource_id, :compute_resource_name,
          :owner, :owner_id, :owner_name,
          :owner_type,
          :compute_attributes => {}

        add_host_base_params_filter(filter)
        add_host_common_params_filter(filter)

        facets = Facets.registered_facets.values.map { |facet_config| "#{facet_config.name}_attributes" }
        filter.permit(*facets) if facets.present?
      end
    end
  end

  def host_params(top_level_hash = controller_name.singularize)
    self.class.host_params_filter.filter_params(params, parameter_filter_context, top_level_hash).tap do |normalized|
      if parameter_filter_context.ui? && normalized["compute_attributes"] && normalized["compute_attributes"]["scsi_controllers"]
        normalize_scsi_attributes(normalized["compute_attributes"])
      end
    end
  end
end
