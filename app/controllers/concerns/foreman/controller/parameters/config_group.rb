module Foreman::Controller::Parameters::ConfigGroup
  extend ActiveSupport::Concern

  class_methods do
    def config_group_params_filter
      Foreman::ParameterFilter.new(::ConfigGroup).tap do |filter|
        filter.permit :name,
          :class_environments => [],
          :puppetclass_ids => [], :puppetclass_names => []
      end
    end
  end

  def config_group_params
    self.class.config_group_params_filter.filter_params(params, parameter_filter_context)
  end
end
