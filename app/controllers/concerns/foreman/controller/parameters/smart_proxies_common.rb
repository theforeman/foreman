module Foreman::Controller::Parameters::SmartProxiesCommon
  extend ActiveSupport::Concern

  class_methods do
    def add_smart_proxies_common_params_filter(filter)
      filter.resource_class.registered_smart_proxies.keys.each do |proxy_hostname|
        filter.permit proxy_hostname, :"#{proxy_hostname}_id", :"#{proxy_hostname}_name"
      end
      filter
    end
  end
end
