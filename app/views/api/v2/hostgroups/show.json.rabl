object @hostgroup

extends "api/v2/hostgroups/main"

child :group_parameters => :parameters do
  extends "api/v2/parameters/base"
end

child :template_combinations do
  extends "api/v2/template_combinations/base"
end

child :puppetclasses do
  extends "api/v2/puppetclasses/base"
end
