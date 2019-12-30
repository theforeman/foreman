module Foreman::Controller::Parameters::Puppetclass
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::PuppetclassLookupKey

  class_methods do
    def puppetclass_params_filter
      Foreman::ParameterFilter.new(::Puppetclass).tap do |filter|
        filter.permit :name,
          :class_params_attributes => [puppetclass_lookup_key_params_filter],
          :hostgroup_ids => [], :hostgroup_names => [],
          :smart_class_parameters => [puppetclass_lookup_key_params_filter],
          :smart_class_parameter_ids => [], :smart_class_parameter_names => []
      end
    end
  end

  def puppetclass_params
    self.class.puppetclass_params_filter.filter_params(params, parameter_filter_context)
  end
end
