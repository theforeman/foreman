module Foreman::Controller::Parameters::TemplateCombination
  extend ActiveSupport::Concern

  class_methods do
    def template_combination_params_filter
      Foreman::ParameterFilter.new(::TemplateCombination).tap do |filter|
        filter.permit :environment_id, :environment_name, :environment,
          :hostgroup_id, :hostgroup_name, :hostgroup
      end
    end
  end

  def template_combination_params
    self.class.template_combination_params_filter.filter_params(params, parameter_filter_context)
  end
end
