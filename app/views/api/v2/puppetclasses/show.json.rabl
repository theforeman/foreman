object @puppetclass

extends "api/v2/puppetclasses/main"

child :environments do
  extends "api/v2/environments/base"
end

child :all_hostgroups => :hostgroups do
  extends "api/v2/hostgroups/base"
end

node do |puppetclass|
  { :smart_variables => partial("api/v2/smart_variables/base", :object => puppetclass.lookup_keys) }
end

node do |puppetclass|
  { :smart_class_parameters => partial("api/v2/smart_class_parameters/base", :object => puppetclass.class_params) }
end
