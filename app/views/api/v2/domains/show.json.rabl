object @domain

extends "api/v2/domains/main"

child :subnets do
  extends "api/v2/subnets/base"
end

node do |domain|
  { :parameters => partial("api/v2/parameters/base", :object => domain.lookup_values.globals.authorized) }
end

node do |domain|
  partial("api/v2/taxonomies/children_nodes", :object => domain)
end

child :interfaces => :interfaces do
  extends "api/v2/interfaces/base"
end
