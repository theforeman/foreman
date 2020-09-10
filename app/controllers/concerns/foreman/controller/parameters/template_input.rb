module Foreman::Controller::Parameters::TemplateInput
  extend ActiveSupport::Concern

  class_methods do
    def template_input_params_filter
      Foreman::ParameterFilter.new(::TemplateInput).tap do |filter|
        filter.permit_by_context :id, :_destroy, :name, :required, :input_type, :fact_name, :resource_type, :value_type,
          :variable_name, :puppet_class_name, :puppet_parameter_name, :description, :template_id,
          :options, :default, :advanced, :hidden_value, :nested => true
      end
    end
  end

  def template_input_params
    self.class.template_input_params_filter.filter_params(params, parameter_filter_context, :template_input)
  end
end
