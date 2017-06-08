module Foreman::Controller::Parameters::Hostname
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::Taxonomix

  class_methods do
    def hostname_params_filter
      Foreman::ParameterFilter.new(::Hostname).tap do |filter|
        filter.permit :name,
          :hostname,
          :smart_proxy_ids => []
        add_taxonomix_params_filter(filter)
      end
    end
  end

  def hostname_params
    self.class.hostname_params_filter.filter_params(params, parameter_filter_context)
  end
end
