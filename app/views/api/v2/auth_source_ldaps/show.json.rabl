object @auth_source_ldap

extends "api/v2/auth_source_ldaps/main"

node do |auth_source_ldap|
  partial("api/v2/taxonomies/children_nodes", :object => auth_source_ldap)
end

child :external_usergroups do
  extends "api/v2/external_usergroups/base"
end
