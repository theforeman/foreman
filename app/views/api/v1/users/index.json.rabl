collection @users

attributes :id, :login, :firstname, :lastname, :mail, :admin, :auth_source_id, :role_id, :last_login_on,
           :created_at, :updated_at

node(:domains_andor) { 'or' }
node(:hostgroups_andor) { 'or' }
node(:facts_andor) { 'or' }
node(:compute_resources_andor) { 'or' }
node(:filter_on_owner) { nil }
