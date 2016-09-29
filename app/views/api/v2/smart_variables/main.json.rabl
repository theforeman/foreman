object @smart_variable

extends "api/v2/smart_variables/base"

attributes :description, :parameter_type, :default_value, :hidden_value?, :hidden_value, :validator_type, :validator_rule,
           :override_value_order, :override_values_count, :merge_overrides, :merge_default, :avoid_duplicates,
           :puppetclass_id, :puppetclass_name, :created_at, :updated_at

node :override_values_count do |lk|
  lk.lookup_values.count
end
