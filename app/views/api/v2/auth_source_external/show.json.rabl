object @auth_source_external

extends "api/v2/auth_source_external/main"

node do |auth_source_external|
  partial("api/v2/taxonomies/children_nodes", :object => auth_source_external)
end
