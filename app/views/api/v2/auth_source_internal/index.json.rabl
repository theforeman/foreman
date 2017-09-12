collection @auth_source_internal

extends "api/v2/auth_source_internal/main"

node do |auth_source_internal|
   partial("api/v2/taxonomies/children_nodes", :object => auth_source_internal)
end
