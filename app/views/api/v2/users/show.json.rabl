object @user

extends "api/v2/users/main"

child :auth_source do
  extends "api/v2/auth_source_ldaps/base"
end

child :roles, :object_root => false do
  extends "api/v2/roles/base"
end