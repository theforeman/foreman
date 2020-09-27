object @lookup_key

extends 'api/v2/lookup_keys/base'

node :override_values_count do |lk|
  lk.lookup_values.count
end

attributes :description, :override, :parameter_type, :hidden_value?,
  :omit, :required, :validator_type, :validator_rule, :merge_overrides,
  :merge_default, :avoid_duplicates, :override_value_order, :created_at, :updated_at

node do
  partial('api/v2/common/show_hidden', :locals => { :value => :default_value }, :object => @object)
end
