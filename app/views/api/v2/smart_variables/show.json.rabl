object @smart_variable

extends "api/v2/smart_variables/main"

node do |smart_variable|
  { :override_values => partial("api/v2/override_values/index", :object => smart_variable.lookup_values) }
end
