module Foreman::Controller::Parameters::ComputeAttribute
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::KeepParam

  class_methods do
    def compute_attribute_params_filter
      Foreman::ParameterFilter.new(::ComputeAttribute).tap do |filter|
        filter.permit :compute_profile_id,
          :compute_resource_id
      end
    end
  end

  def compute_attribute_params
    keep_param(params, controller_name.singularize, :vm_attrs) do
      self.class.compute_attribute_params_filter.filter_params(params, parameter_filter_context)
    end
  end
end
