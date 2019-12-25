object @smart_class_parameter

extends "api/v2/smart_class_parameters/base"

node :puppetclass_id do |lk|
  lk.param_class.id
end

node :override_values_count do |lk|
  lk.lookup_values.count
end

attributes :description, :override, :parameter_type, :hidden_value?,
  :omit, :required, :validator_type, :validator_rule, :merge_overrides,
  :merge_default, :avoid_duplicates, :override_value_order, :created_at, :updated_at

node do
  partial("api/v2/common/show_hidden", :locals => { :value => :default_value }, :object => @object)
end

node :puppetclass_name do |lk|
  lk.param_class.name
end
