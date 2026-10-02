object @usergroup

extends "api/v2/usergroups/base"

attributes :admin, :created_at, :updated_at

child :locations => :locations do
  attributes :id, :name, :title
end

child :organizations => :organizations do
  attributes :id, :name, :title
end
