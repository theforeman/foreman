object @common_parameter

extends "api/v2/common_parameters/base"

attributes :description, :override, :parameter_type, :default_value, :hidden_value?, :hidden_value,
           :omit, :required, :validator_type, :validator_rule, :merge_overrides,
           :merge_default, :avoid_duplicates, :override_value_order, :override_values_count, :created_at, :updated_at