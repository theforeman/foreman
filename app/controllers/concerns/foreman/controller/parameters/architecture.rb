module Foreman::Controller::Parameters::Architecture
  extend ActiveSupport::Concern

  class_methods do
    def architecture_params_filter
      Foreman::ParameterFilter.new(::Architecture).tap do |filter|
        filter.permit :name,
          :host_names => [], :host_ids => [],
          :hostgroup_ids => [], :hostgroup_names => [],
          :image_names => [], :image_ids => [],
          :operatingsystem_ids => [], :operatingsystem_names => []
      end
    end
  end

  def architecture_params
    self.class.architecture_params_filter.filter_params(params, parameter_filter_context)
  end
end
