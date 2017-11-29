module Foreman::Controller::Parameters::Parameter
  extend ActiveSupport::Concern

  class_methods do
    def parameter_params_filter(type)
      Foreman::ParameterFilter.new(type).tap do |filter|
        filter.permit :host_id,
          :hostgroup_id,
          :domain_id,
          :operatingsystem_id,
          :location_id,
          :organization_id,
          :subnet_id

        filter.permit_by_context :hidden_value,
          :name,
          :nested,
          :reference_id,
          :value,
          :parameter_type,
          :nested => true

        filter.permit_by_context :id,
          :_destroy,
          :ui => false, :api => false, :nested => true
      end
    end
  end

  def parameter_params(type)
    self.class.parameter_params_filter(type).filter_params(params, parameter_filter_context)
  end
end
