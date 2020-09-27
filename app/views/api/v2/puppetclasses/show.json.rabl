object @puppetclass

extends "api/v2/puppetclasses/main"

child :environments do
  extends "api/v2/environments/base"
end

child :all_hostgroups => :hostgroups do
  extends "api/v2/hostgroups/base"
end

node do |puppetclass|
  { :smart_class_parameters => partial("api/v2/lookup_keys/base", :object => puppetclass.class_params) }
end
