module Foreman::Controller::Parameters::Subnet
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::Parameter
  include Foreman::Controller::Parameters::Taxonomix

  class_methods do
    def subnet_params_filter
      Foreman::ParameterFilter.new(::Subnet).tap do |filter|
        filter.permit :boot_mode,
          :cidr,
          :dhcp, :dhcp_id,
          :dns, :dns_id,
          :dns_primary,
          :dns_secondary,
          :from,
          :gateway,
          :ipam,
          :mask,
          :name,
          :network,
          :network_type,
          :tftp, :tftp_id,
          :to,
          :type,
          :vlanid,
          :domain_ids => [], :domain_names => [],
          :subnet_parameters_attributes => [parameter_params_filter(::SubnetParameter)]
        add_taxonomix_params_filter(filter)
      end
    end
  end

  def subnet_params
    self.class.subnet_params_filter.filter_params(params, parameter_filter_context)
  end
end
