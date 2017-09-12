collection @auth_source

extends "api/v2/auth_source/main"

node do |auth_source|
   partial("api/v2/taxonomies/children_nodes", :object => auth_source)
end
