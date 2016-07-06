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
          :user

        # ec2
        filter.permit :access_key,
          :region

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
          :tenant

        # ovirt
        filter.permit :datacenter,
          :ovirt_quota,
          :public_key,
          :uuid

        # rackspace
        filter.permit :region

        # vmware
        filter.permit :datacenter,
          :pubkey_hash,
          :server,
          :uuid

        add_taxonomix_params_filter(filter)
      end
    end
  end

  def compute_resource_params
    self.class.compute_resource_params_filter.filter_params(params, parameter_filter_context)
  end
end
