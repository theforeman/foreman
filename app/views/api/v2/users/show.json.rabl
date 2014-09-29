object @user

extends "api/v2/users/main"

child :auth_source do
  extends "api/v2/auth_source_ldaps/base"
end

child :mail_notifications do
  extends "api/v2/mail_notifications/base"
end

child :roles do
  extends "api/v2/roles/base"
end

child :usergroups do
  extends "api/v2/usergroups/base"
end

node do |user|
  partial("api/v2/taxonomies/children_nodes", :object => user)
end
