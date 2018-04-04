module Foreman::Controller::Parameters::ProvisioningTemplate
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::Taxonomix
  include Foreman::Controller::Parameters::Template
  include Foreman::Controller::Parameters::TemplateCombination

  class_methods do
    def provisioning_template_params_filter
      Foreman::ParameterFilter.new(::ProvisioningTemplate).tap do |filter|
        filter.permit :template_combinations_attributes => [template_combination_params_filter],
          :operatingsystems => [], :operatingsystem_ids => [], :operatingsystem_names => []
        add_taxonomix_params_filter(filter)
        add_template_params_filter(filter)
      end
    end
  end

  def provisioning_template_params
    self.class.provisioning_template_params_filter.filter_params(params, parameter_filter_context)
  end

  def organization_params
    self.class.organization_params_filter(::ProvisioningTemplate).filter_params(params, parameter_filter_context)
  end

  def location_params
    self.class.location_params_filter(::ProvisioningTemplate).filter_params(params, parameter_filter_context)
  end
end
