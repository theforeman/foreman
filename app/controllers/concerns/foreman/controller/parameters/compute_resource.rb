module Foreman::Controller::Parameters::ComputeResource
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::Taxonomix

  class_methods do
    def compute_resource_params_filter
      Foreman::ParameterFilter.new(::ComputeResource).tap do |filter|
        filter.permit :description,
          :display_type,
          :name,
          :password,
          :provider,
          :set_console_password,
          :url,
          :http_proxy_id,
          :user

        # ec2
        filter.permit :access_key,
          :region,
          :gov_cloud

        # gce
        filter.permit :email,
          :key_pair,
          :key_path,
          :project,
          :zone

        # libvirt
        filter.permit :display_type,
          :uuid

        # openstack
        filter.permit :allow_external_network,
          :key_pair,
          :tenant,
          :domain,
          :project_domain_name,
          :project_domain_id

        # ovirt
        filter.permit :datacenter,
          :ovirt_quota,
          :keyboard_layout,
          :use_v4,
          :public_key,
          :uuid

        # vmware
        filter.permit :datacenter,
          :pubkey_hash,
          :server,
          :uuid,
          :caching_enabled

        add_taxonomix_params_filter(filter)
      end
    end
  end

  def compute_resource_params
    self.class.compute_resource_params_filter.filter_params(params, parameter_filter_context)
  end
end
