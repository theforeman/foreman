module Foreman::Controller::Parameters::Role
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::Taxonomix

  class_methods do
    def role_params_filter
      Foreman::ParameterFilter.new(::Role).tap do |filter|
        filter.permit :name
        filter.permit :description
        add_taxonomix_params_filter(filter)
      end
    end
  end

  def role_params
    self.class.role_params_filter.filter_params(params, parameter_filter_context)
  end
end
