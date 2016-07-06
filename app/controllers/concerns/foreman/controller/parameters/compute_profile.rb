module Foreman::Controller::Parameters::ComputeProfile
  extend ActiveSupport::Concern

  class_methods do
    def compute_profile_params_filter
      Foreman::ParameterFilter.new(::ComputeProfile).tap do |filter|
        filter.permit :name
      end
    end
  end

  def compute_profile_params
    self.class.compute_profile_params_filter.filter_params(params, parameter_filter_context)
  end
end
