module Foreman::Controller::Parameters::OsDefaultTemplate
  extend ActiveSupport::Concern

  class_methods do
    def os_default_template_params_filter
      Foreman::ParameterFilter.new(::OsDefaultTemplate).tap do |filter|
        filter.permit_by_context :provisioning_template_id, :provisioning_template_name,
          :template_kind_id, :template_kind_name,
          :operatingsystem, :operatingsystem_id, :operatingsystem_name,
          :nested => true

        filter.permit_by_context :id,
          :_destroy,
          :ui => false, :api => false, :nested => true
      end
    end
  end

  def os_default_template_params
    self.class.os_default_template_params_filter.filter_params(params, parameter_filter_context)
  end
end
