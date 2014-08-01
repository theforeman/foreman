object @usergroup

extends "api/v2/usergroups/main"

child :external_usergroups do
  extends "api/v2/external_usergroups/base"
end

child :usergroups do
  extends "api/v2/usergroups/base"
end

child :users do
  extends "api/v2/users/base"
end

child :roles do
  extends "api/v2/roles/base"
end
