object @environment

extends "api/v2/environments/main"

child :config_templates, :object_root => false do
  extends "api/v2/config_templates/base"
end

child :template_combinations, :object_root => false do
  extends "api/v2/template_combinations/base"
end

child :puppetclasses, :object_root => false do
  extends "api/v2/puppetclasses/base"
end

node do |environment|
   partial("api/v2/taxonomies/children_nodes", :object => environment)
end
