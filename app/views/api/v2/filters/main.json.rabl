object @filter

extends "api/v2/filters/base"

attributes :search, :role_id, :created_at, :updated_at

child :permissions => :permissions do
  attributes :id, :name
end

child :organizations => :organizations do
  attributes :id, :name
end

child :locations => :locations do
  attributes :id, :name
end