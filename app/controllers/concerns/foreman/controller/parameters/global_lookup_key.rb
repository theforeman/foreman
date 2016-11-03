module Foreman::Controller::Parameters::GlobalLookupKey
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::LookupKey

  class_methods do
    def global_lookup_key_params_filter
      Foreman::ParameterFilter.new(::GlobalLookupKey).tap do |filter|
        filter.permit :puppetclass

        filter.permit_by_context :id,
                                 :_destroy,
                                 :ui => false, :api => false, :nested => true

        add_lookup_key_params_filter(filter)
      end
    end
  end

  def global_lookup_key_params
    self.class.global_lookup_key_params_filter.filter_params(params, parameter_filter_context)
  end
end
