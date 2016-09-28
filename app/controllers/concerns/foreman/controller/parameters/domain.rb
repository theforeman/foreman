module Foreman::Controller::Parameters::Domain
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::Parameter
  include Foreman::Controller::Parameters::Taxonomix
  include Foreman::Controller::Parameters::SmartProxiesCommon

  class_methods do
    def domain_params_filter
      Foreman::ParameterFilter.new(::Domain).tap do |filter|
        filter.permit :fullname,
          :name,
          :domain_parameters_attributes => [parameter_params_filter(DomainParameter)]
        add_taxonomix_params_filter(filter)
        add_smart_proxies_common_params_filter(filter)
      end
    end
  end

  def domain_params
    self.class.domain_params_filter.filter_params(params, parameter_filter_context)
  end
end
