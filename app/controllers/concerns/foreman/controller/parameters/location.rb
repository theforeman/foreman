module Foreman::Controller::Parameters::Location
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::Parameter
  include Foreman::Controller::Parameters::Taxonomy

  class_methods do
    def location_params_filter
      Foreman::ParameterFilter.new(::Location).tap do |filter|
        filter.permit :location_parameters_attributes => [parameter_params_filter(LocationParameter)]
        add_taxonomy_params_filter(filter)
      end
    end
  end

  def location_params
    self.class.location_params_filter.filter_params(params, parameter_filter_context)
  end
end
