object @usergroup

extends "api/v2/usergroups/main"

child :usergroups do
  extends "api/v2/usergroups/base"
end

child :users do
  extends "api/v2/users/base"
end
