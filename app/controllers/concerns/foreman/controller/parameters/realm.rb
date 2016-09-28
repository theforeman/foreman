module Foreman::Controller::Parameters::Realm
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::Taxonomix
  include Foreman::Controller::Parameters::SmartProxiesCommon

  class_methods do
    def realm_params_filter
      Foreman::ParameterFilter.new(::Realm).tap do |filter|
        filter.permit :name,
          :realm_type,
          :realm_proxy, :realm_proxy_id, :realm_proxy_name
        add_taxonomix_params_filter(filter)
        add_smart_proxies_common_params_filter(filter)
      end
    end
  end

  def realm_params
    self.class.realm_params_filter.filter_params(params, parameter_filter_context)
  end
end
