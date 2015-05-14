object @config_template => :config_template

extends "api/v2/config_templates/main"

attributes :template, :locked

child :template_combinations do
  extends "api/v2/template_combinations/base"
end

child :operatingsystems do
  extends "api/v2/operatingsystems/base"
end

child :os_default_templates do
  extends "api/v2/os_default_templates/base"
end

node do |config_template|
  partial("api/v2/taxonomies/children_nodes", :object => config_template)
end
