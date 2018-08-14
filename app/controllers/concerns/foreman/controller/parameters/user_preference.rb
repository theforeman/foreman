module Foreman::Controller::Parameters::UserPreference
  extend ActiveSupport::Concern

  class_methods do
    def user_preference_params_filter
      Foreman::ParameterFilter.new(::UserPreference).tap do |filter|
        filter.permit :name, :kind, value: {}
      end
    end
  end

  def user_preference_params
    self.class.user_preference_params_filter.filter_params(params, parameter_filter_context)
  end
end
