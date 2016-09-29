object @provisioning_template

extends "api/v2/provisioning_templates/main"

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

node do |provisioning_template|
  partial("api/v2/taxonomies/children_nodes", :object => provisioning_template)
end
