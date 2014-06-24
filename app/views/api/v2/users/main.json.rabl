object @user

extends "api/v2/users/base"

attributes :firstname, :lastname, :mail, :admin, :auth_source_id, :auth_source_name, :last_login_on, :created_at, :updated_at

if SETTINGS[:locations_enabled]
  child :default_location => :default_location do
    extends "api/v2/taxonomies/base", :taxonomy => :location
  end
end

if SETTINGS[:organizations_enabled]
  child :default_organization => :default_organization do
    extends "api/v2/taxonomies/base"
  end
end

