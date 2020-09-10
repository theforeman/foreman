module Foreman::Controller::Parameters::LookupKey
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::LookupValue

  class_methods do
    def add_lookup_key_params_filter(filter)
      filter.permit_by_context :avoid_duplicates,
        :default_value,
        :description,
        :hidden_value,
        :key,
        :key_type,
        :merge_default,
        :merge_overrides,
        :override,
        :override_value_order,
        :parameter_type,
        :path,
        :puppetclass_id,
        :omit,
        :validator_rule,
        :validator_type,
        :variable,
        :variable_type,
        {:lookup_values_attributes => [lookup_value_params_filter],
        :lookup_values => [lookup_value_params_filter], :lookup_value_ids => [],
        :override_values => [lookup_value_params_filter], :override_value_ids => []},
        :nested => true
    end
  end
end
