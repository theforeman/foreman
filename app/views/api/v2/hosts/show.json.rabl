object @host

extends "api/v2/hosts/main"

child :host_parameters, :object_root => false do
  attributes :id, :name, :value, :priority, :is_property, :created_at, :updated_at
end

node do |host|
   { :interfaces => partial("api/v2/interfaces/show", :object => host.interfaces) }
end
