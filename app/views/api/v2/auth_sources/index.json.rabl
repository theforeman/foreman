collection @auth_sources

extends "api/v2/auth_sources/main"

node do |auth_source|
  partial("api/v2/taxonomies/children_nodes", :object => auth_source)
end
