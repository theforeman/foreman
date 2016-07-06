module Foreman::Controller::Parameters::ExternalUsergroup
  extend ActiveSupport::Concern

  class_methods do
    def external_usergroup_params_filter
      Foreman::ParameterFilter.new(::ExternalUsergroup).tap do |filter|
        filter.permit :usergroup, :usergroup_id, :usergroup_name
        filter.permit_by_context :auth_source_id, :auth_source_name,
          :name,
          :nested => true
        filter.permit_by_context :id,
          :_destroy,
          :ui => false, :api => false, :nested => true
      end
    end
  end

  def external_usergroup_params
    self.class.external_usergroup_params_filter.filter_params(params, parameter_filter_context)
  end
end
