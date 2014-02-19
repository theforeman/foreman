object @usergroup

extends "api/v2/usergroups/main"

child :usergroups, :object_root => false do
  extends "api/v2/usergroups/base"
end

child :users, :object_root => false do
  extends "api/v2/users/base"
end
