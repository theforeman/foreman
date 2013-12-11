object @puppetclass

extends "api/v2/puppetclasses/main"

child :environments, :object_root => false do
  extends "api/v2/environments/base"
end

child :hostgroups, :object_root => false do
  extends "api/v2/hostgroups/base"
end

node do |puppetclass|
  { :smart_variables => partial("api/v2/smart_variables/base", :object => puppetclass.lookup_keys) }
end

node do |puppetclass|
  { :smart_class_parameters => partial("api/v2/smart_class_parameters/base", :object => puppetclass.class_params) }
end

