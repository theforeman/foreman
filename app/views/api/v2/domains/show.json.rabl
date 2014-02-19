object @domain

extends "api/v2/domains/main"

child :subnets, :object_root => false do
  extends "api/v2/subnets/base"
end

node do |domain|
   { :parameters => partial("api/v2/parameters/base", :object => domain.parameters) }
end

node do |domain|
   { :interfaces => partial("api/v2/interfaces/base", :object => domain.interfaces) }
end
