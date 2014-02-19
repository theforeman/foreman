object @host

extends "api/v2/hosts/main"

child :host_parameters => :parameters do
  extends "api/v2/puppetclasses/base"
end

child :interfaces => :interfaces do
  extends "api/v2/interfaces/base"
end

child :puppetclasses do
  extends "api/v2/puppetclasses/base"
end
