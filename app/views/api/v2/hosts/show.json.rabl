object @host

extends "api/v2/hosts/main"

child :host_parameters => :parameters do
  extends "api/v2/parameters/base"
end

child :interfaces => :interfaces do
  extends "api/v2/interfaces/base"
end

child :puppetclasses do
  extends "api/v2/puppetclasses/base"
end

node do |host|
  { :all_puppetclasses => partial("api/v2/puppetclasses/base", :object => host.all_puppetclasses) }
end

child :config_groups do
  extends "api/v2/config_groups/main"
end
