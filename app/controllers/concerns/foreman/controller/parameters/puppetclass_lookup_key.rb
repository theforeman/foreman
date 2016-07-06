module Foreman::Controller::Parameters::PuppetclassLookupKey
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::LookupKey

  class_methods do
    def puppetclass_lookup_key_params_filter
      Foreman::ParameterFilter.new(::PuppetclassLookupKey).tap do |filter|
        filter.permit :environments => [], :environment_ids => [], :environment_names => [],
          :environment_classes => [], :environment_classes_ids => [], :environment_classes_names => [],
          :param_classes => [], :param_classes_ids => [], :param_classes_names => []
        filter.permit_by_context :required, :nested => true
        filter.permit_by_context :id, :ui => false, :api => false, :nested => true

        add_lookup_key_params_filter(filter)
      end
    end
  end

  def puppetclass_lookup_key_params
    self.class.puppetclass_lookup_key_params_filter.filter_params(params, parameter_filter_context)
  end
end
