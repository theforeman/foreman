module Foreman::Controller::Parameters::Organization
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::Parameter
  include Foreman::Controller::Parameters::Taxonomy

  class_methods do
    def organization_params_filter
      Foreman::ParameterFilter.new(::Organization).tap do |filter|
        filter.permit :organization_parameters_attributes => [parameter_params_filter(OrganizationParameter)]
        add_taxonomy_params_filter(filter)
      end
    end
  end

  def organization_params
    self.class.organization_params_filter.filter_params(params, parameter_filter_context)
  end
end
