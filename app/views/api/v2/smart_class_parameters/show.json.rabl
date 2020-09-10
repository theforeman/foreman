object @smart_class_parameter

extends "api/v2/smart_class_parameters/main"

unless params[:puppetclass_id].present?
  node do |smart_class_parameter|
    { :puppetclass => partial("api/v2/puppetclasses/base", :object => smart_class_parameter.param_class) }
  end
end

unless params[:environment_id].present?
  child :environments do
    attributes :id, :name
  end
end

node do |smart_class_parameter|
  { :override_values => partial("api/v2/override_values/index", :object => smart_class_parameter.lookup_values) }
end
