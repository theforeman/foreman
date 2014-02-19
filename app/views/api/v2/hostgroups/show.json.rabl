object @hostgroup

extends "api/v2/hostgroups/main"

node do |hostgroup|
   { :parameters => partial("api/v2/parameters/base", :object => hostgroup.group_parameters) }
end

child :config_templates, :object_root => false do
  extends "api/v2/config_templates/base"
end

child :template_combinations, :object_root => false do
  extends "api/v2/template_combinations/base"
end

child :puppetclasses, :object_root => false do
  extends "api/v2/puppetclasses/base"
end
