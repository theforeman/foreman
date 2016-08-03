object @role

extends "api/v2/roles/main"

child :filters => :filters do
  extends "api/v2/filters/base"
end

node do |role|
  partial("api/v2/taxonomies/children_nodes", :object => role)
end
