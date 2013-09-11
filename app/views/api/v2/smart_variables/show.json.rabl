object @smart_variable => :smart_variable

extends "api/v2/smart_variables/base"
attributes :description, :parameter_type, :default_value, :validator_type, :validator_rule, :override_value_order, :override_values_count,
           :puppetclass_id, :puppetclass_name, :created_at, :updated_at

node do |smart_variable|
  { :override_values => partial("api/v2/override_values/show", :object => smart_variable.lookup_values) }
end

