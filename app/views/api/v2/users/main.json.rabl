object @user

extends "api/v2/users/base"

attributes :firstname, :lastname, :mail, :admin, :auth_source_id, :disabled, :auth_source_name, :timezone, :locale, :last_login_on, :created_at, :updated_at

child :ssh_keys do
  extends "api/v2/ssh_keys/base"
end

node(:effective_admin) { |u| u.admin? }

child :default_location => :default_location do
  extends "api/v2/taxonomies/base", :taxonomy => :location
end
child :locations => :locations do
  attributes :id, :name
end

child :default_organization => :default_organization do
  extends "api/v2/taxonomies/base"
end
child :organizations => :organizations do
  attributes :id, :name
end
