module Foreman::Controller::Parameters::SmartProxyPool
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::Taxonomix

  class_methods do
    def smart_proxy_pool_params_filter
      Foreman::ParameterFilter.new(::SmartProxyPool).tap do |filter|
        filter.permit :name,
          :hostname,
          :smart_proxies => [], :smart_proxy_ids => []
        add_taxonomix_params_filter(filter)
      end
    end
  end

  def smart_proxy_pool_params
    self.class.smart_proxy_pool_params_filter.filter_params(params, parameter_filter_context)
  end
end
