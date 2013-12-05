object @config_template

extends "api/v2/config_templates/main"

attributes :template

child :template_combinations, :object_root => false do
  extends "api/v2/template_combinations/base"
end

child :operatingsystems, :object_root => false do
  extends "api/v2/operatingsystems/base"
end
