object @smart_class_parameter => :smart_class_parameter

extends "api/v2/smart_class_parameters/base"
attributes :description, :override, :parameter_type, :default_value, :required, :validator_type, :validator_rule,
           :override_value_order, :override_values_count, :created_at, :updated_at

unless params[:puppetclass_id].present?
  node do |smart_class_parameter|
    { :puppetclass => partial("api/v2/puppetclasses/base", :object => smart_class_parameter.param_class) }
  end
end

unless params[:environment_id].present?
  child :environments, :object_root => false do
    attributes :id, :name
  end
end

node do |smart_class_parameter|
  { :override_values => partial("api/v2/override_values/show", :object => smart_class_parameter.lookup_values) }
end
