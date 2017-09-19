object @hostgroup

extends "api/v2/hostgroups/main"

child :template_combinations do
  extends "api/v2/template_combinations/base"
end

child :puppetclasses do
  extends "api/v2/puppetclasses/base"
end

node do |hostgroup|
  { :all_puppetclasses => partial("api/v2/puppetclasses/base", :object => hostgroup.all_puppetclasses) }
end

child :config_groups do
  extends "api/v2/config_groups/main"
end

node do |hostgroup|
  partial("api/v2/taxonomies/children_nodes", :object => hostgroup)
end
