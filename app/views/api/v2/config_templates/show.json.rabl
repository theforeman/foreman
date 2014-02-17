object @config_template

extends "api/v2/config_templates/main"

attributes :template

child :template_combinations, :object_root => false do
  extends "api/v2/template_combinations/base"
end

child :operatingsystems, :object_root => false do
  extends "api/v2/operatingsystems/base"
end

child :environments, :object_root => false do
  extends "api/v2/environments/base"
end

child :os_default_templates, :object_root => false do
  extends "api/v2/os_default_templates/base"
end

node do |config_template|
   partial("api/v2/taxonomies/children_nodes", :object => config_template)
end

