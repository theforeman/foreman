object @external_usergroup

extends "api/v2/external_usergroups/base"

child :auth_source do
  extends "api/v2/auth_source_ldaps/base"
end
