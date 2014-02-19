  object @host

extends "api/v2/hosts/main"

node do |host|
   { :parameters => partial("api/v2/parameters/base", :object => host.host_parameters) }
end

node do |host|
   { :interfaces => partial("api/v2/interfaces/base", :object => host.interfaces) }
end

child :puppetclasses, :object_root => false do
  extends "api/v2/puppetclasses/base"
end
