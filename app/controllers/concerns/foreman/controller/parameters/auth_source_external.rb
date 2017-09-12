module Foreman::Controller::Parameters::AuthSourceExternal
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::Taxonomix

  class_methods do
    def auth_source_external_params_filter
      Foreman::ParameterFilter.new(::AuthSourceExternal).tap do |filter|
        filter.permit :name

        add_taxonomix_params_filter(filter)
      end
    end
  end

  def auth_source_external_params
    self.class.auth_source_external_params_filter.filter_params(params, parameter_filter_context)
  end
end
