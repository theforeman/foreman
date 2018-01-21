module Foreman::Controller::Parameters::Operatingsystem
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::OsDefaultTemplate
  include Foreman::Controller::Parameters::Parameter

  class_methods do
    def operatingsystem_params_filter
      Foreman::ParameterFilter.new(::Operatingsystem).tap do |filter|
        filter.permit :description,
          :family,
          :major,
          :minor,
          :name,
          :password_hash,
          :release_name,
          :to_label,
          :architectures => [:id, :name], :architecture_ids => [], :architecture_names => [],
          :medium_ids => [], :medium_names => [],
          :os_default_templates_attributes => [os_default_template_params_filter],
          :os_parameters_attributes => [parameter_params_filter(OsParameter)],
          :provisioning_templates => [], :provisioning_template_names => [], :provisioning_template_ids => [],
          :ptable_ids => [], :ptable_names => []
      end
    end
  end

  def operatingsystem_params
    self.class.operatingsystem_params_filter.filter_params(params, parameter_filter_context)
  end
end
