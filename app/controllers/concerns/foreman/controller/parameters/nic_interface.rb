module Foreman::Controller::Parameters::NicInterface
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::NicBase

  class_methods do
    def nic_interface_params_filter
      Foreman::ParameterFilter.new(::Nic::Interface).tap do |filter|
        filter.permit_by_context :domain, :domain_id,
          :name,
          :subnet, :subnet_id,
          :subnet6, :subnet6_id,
          :nested => true
        add_nic_base_params_filter(filter)
      end
    end
  end

  def nic_interface_params
    self.class.nic_interface_params_filter.filter_params(params, parameter_filter_context)
  end
end
