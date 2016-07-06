module Foreman::Controller::Parameters::Image
  extend ActiveSupport::Concern

  class_methods do
    def image_params_filter
      Foreman::ParameterFilter.new(::Image).tap do |filter|
        filter.permit :architecture_id, :architecture_name,
          :compute_resource_id, :compute_resource_name,
          :iam_role,
          :name,
          :operatingsystem_id, :operatingsystem_name,
          :password,
          :user_data,
          :username,
          :uuid
      end
    end
  end

  def image_params
    self.class.image_params_filter.filter_params(params, parameter_filter_context)
  end
end
