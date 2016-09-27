module Foreman::Controller::Parameters::Parameter
  extend ActiveSupport::Concern

  class_methods do
    def parameter_params_filter
      Foreman::ParameterFilter.new(::Parameter).tap do |filter|
        filter.permit_by_context :hidden_value,
          :name,
          :key,
          :nested,
          :reference_id,
          :should_be_global,
          :value,
          :nested => true

        filter.permit_by_context :id,
          :_destroy,
          :ui => false, :api => false, :nested => true
      end
    end
  end

  def parameter_params
    self.class.parameter_params_filter.filter_params(params, parameter_filter_context)
  end
end
