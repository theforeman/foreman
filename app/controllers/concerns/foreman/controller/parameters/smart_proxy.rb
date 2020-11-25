module Foreman::Controller::Parameters::SmartProxy
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::Taxonomix

  class_methods do
    def smart_proxy_params_filter
      Foreman::ParameterFilter.new(::SmartProxy).tap do |filter|
        filter.permit :name,
          :url,
          :uuid
        add_taxonomix_params_filter(filter)
      end
    end
  end

  def smart_proxy_params
    self.class.smart_proxy_params_filter.filter_params(params, parameter_filter_context)
  end
end
