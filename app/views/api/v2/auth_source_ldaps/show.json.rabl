object @auth_source_ldap

extends "api/v2/auth_source_ldaps/main"

child :external_usergroups do
  extends "api/v2/external_usergroups/base"
end
