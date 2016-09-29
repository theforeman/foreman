object @smart_class_parameter

extends "api/v2/smart_class_parameters/base"

node :puppetclass_id do |lk|
  lk.param_class.id
end

node :override_values_count do |lk|
  lk.lookup_values.count
end

attributes :description, :override, :parameter_type, :default_value, :hidden_value?, :hidden_value,
           :omit, :required, :validator_type, :validator_rule, :merge_overrides,
           :merge_default, :avoid_duplicates, :override_value_order, :created_at, :updated_at

# compatibility
attribute :omit => :use_puppet_default

attribute :param_class, :as => :puppetclass_name
