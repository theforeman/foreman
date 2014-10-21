object @smart_variable

extends "api/v2/smart_variables/base"

attributes :description, :parameter_type, :default_value, :validator_type, :validator_rule,
           :override_value_order, :override_values_count, :merge_overrides, :avoid_duplicates,
           :puppetclass_id, :puppetclass_name, :created_at, :updated_at
