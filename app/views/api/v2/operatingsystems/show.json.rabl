object @operatingsystem

extends "api/v2/operatingsystems/main"

node do |os|
  { :parameters => partial("api/v2/parameters/index", :object => os.parameters.authorized) }
end

child :media do
  extends "api/v2/media/base"
end

child :architectures do
  extends "api/v2/architectures/base"
end

child :ptables => :ptables do
  extends "api/v2/ptables/base"
end

child :provisioning_templates => :provisioning_templates do
  extends "api/v2/provisioning_templates/base"
end

child :os_default_templates do
  extends "api/v2/os_default_templates/base"
end

child :images do
  extends "api/v2/images/base"
end
