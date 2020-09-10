object @subnet

extends "api/v2/subnets/main"

child :domains do
  extends "api/v2/domains/base"
end

node do |subnet|
  { :parameters => partial("api/v2/parameters/index", :object => subnet.parameters.authorized) }
end

node do |subnet|
  partial("api/v2/taxonomies/children_nodes", :object => subnet)
end

child :interfaces => :interfaces do
  extends "api/v2/interfaces/base"
end
