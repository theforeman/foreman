module Foreman::Controller::Parameters::Model
  extend ActiveSupport::Concern

  class_methods do
    def model_params_filter
      Foreman::ParameterFilter.new(::Model).tap do |filter|
        filter.permit :hardware_model,
          :info,
          :name,
          :vendor_class
      end
    end
  end

  def model_params
    self.class.model_params_filter.filter_params(params, parameter_filter_context)
  end
end
