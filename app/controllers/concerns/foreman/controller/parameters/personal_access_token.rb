module Foreman::Controller::Parameters::PersonalAccessToken
  extend ActiveSupport::Concern

  class_methods do
    def personal_access_token_params_filter
      Foreman::ParameterFilter.new(::PersonalAccessToken).tap do |filter|
        filter.permit :name, :expires_at, :user_id
      end
    end
  end

  def personal_access_token_params
    self.class.personal_access_token_params_filter.filter_params(params, parameter_filter_context)
  end
end
