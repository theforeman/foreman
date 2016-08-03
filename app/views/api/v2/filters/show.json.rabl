object @filter

extends "api/v2/filters/main"

node do |filter|
  partial("api/v2/taxonomies/children_nodes", :object => filter)
end
