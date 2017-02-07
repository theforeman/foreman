module Foreman::Controller::Parameters::HostAlias
  extend ActiveSupport::Concern

  class_methods do
    def host_alias_params_filter
      Foreman::ParameterFilter.new(::HostAlias).tap do |filter|
        filter.permit_by_context :nic, :nic_id,
          :name,
          :domain, :domain_id,
          :nested => true

        filter.permit_by_context :id,
          :_destroy,
          :ui => false, :api => false, :nested => true
      end
    end
  end
end
