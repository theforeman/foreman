object @user

attributes :id, :login, :firstname, :lastname, :mail, :admin, :auth_source_id, :role_id, :last_login_on,
           :created_at, :updated_at

node(:domains_andor) { 'or' }
node(:hostgroups_andor) { 'or' }
node(:facts_andor) { 'or' }
node(:compute_resources_andor) { 'or' }
node(:filter_on_owner) { nil }

child :auth_source do
  extends "api/v1/auth_source_ldaps/show"
end

child :roles do
  extends "api/v1/roles/show"
end
