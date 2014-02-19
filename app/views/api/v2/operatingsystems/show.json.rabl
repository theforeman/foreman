object @operatingsystem

extends "api/v2/operatingsystems/main"

node do |operatingsystem|
   { :parameters => partial("api/v2/parameters/base", :object => operatingsystem.parameters) }
end

child :media do
  extends "api/v2/media/base"
end

child :architectures do
  extends "api/v2/architectures/base"
end

child :ptables do
  extends "api/v2/ptables/base"
end

child :config_templates do
  extends "api/v2/config_templates/base"
end

child :os_default_templates do
  extends "api/v2/os_default_templates/base"
end

child :images do
  extends "api/v2/images/base"
end
