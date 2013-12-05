  object @host

extends "api/v2/hosts/main"

child :host_parameters, :object_root => false do
  extends "api/v2/parameters/base"
end

node do |host|
   { :interfaces => partial("api/v2/interfaces/show", :object => host.interfaces) }
end
