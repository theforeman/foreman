module Foreman::Controller::Parameters::LookupValueConnector
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::LookupValue

  class_methods do
    def add_lookup_value_connector_params_filter(filter)
      filter.permit :lookup_value_matcher,
                    :lookup_values_attributes => [lookup_value_params_filter]

    end
  end
end
