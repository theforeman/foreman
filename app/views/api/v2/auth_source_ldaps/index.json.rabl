collection @auth_source_ldaps

extends "api/v2/auth_source_ldaps/main"

node do |auth_source_ldap|
  partial("api/v2/taxonomies/children_nodes", :object => auth_source_ldap)
end
