object @subnet

extends "api/v2/subnets/main"

child :domains, :object_root => false do
  extends "api/v2/domains/base"
end

child :interfaces, :object_root => false do
  extends "api/v2/interfaces/base"
end

node do |subnet|
   { :interfaces => partial("api/v2/interfaces/base", :object => subnet.interfaces) }
end

node do |subnet|
   partial("api/v2/taxonomies/children_nodes", :object => subnet)
end
