module Foreman::Controller::Parameters::HttpProxy
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::Taxonomix

  class_methods do
    def http_proxy_params_filter
      Foreman::ParameterFilter.new(::HttpProxy).tap do |filter|
        filter.permit_by_context :id, :name, :url, :username, :password, :cacert, :nested => true

        add_taxonomix_params_filter(filter)
      end
    end
  end

  def http_proxy_params
    self.class.http_proxy_params_filter.filter_params(params, parameter_filter_context, :http_proxy)
  end
end
