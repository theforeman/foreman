object @user

extends "api/v2/users/base"

attributes :firstname, :lastname, :mail, :admin, :auth_source_id, :auth_source_name, :last_login_on, :created_at, :updated_at

if SETTINGS[:locations_enabled]
  attributes :default_location
end

if SETTINGS[:organizations_enabled]
  attributes :default_organization
end

