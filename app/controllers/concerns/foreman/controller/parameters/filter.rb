module Foreman::Controller::Parameters::Filter
  extend ActiveSupport::Concern

  class_methods do
    def filter_params_filter
      Foreman::ParameterFilter.new(::Filter).tap do |filter|
        filter.permit :resource_type,
          :role_id, :role_name,
          :search,
          :permissions => [], :permission_ids => [], :permission_names => []
      end
    end
  end

  def filter_params
    self.class.filter_params_filter.filter_params(params, parameter_filter_context)
  end
end
