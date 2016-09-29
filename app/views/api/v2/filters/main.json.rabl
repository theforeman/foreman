object @filter

extends "api/v2/filters/base"

attributes :search, :resource_type, :unlimited?, :created_at, :updated_at

child :role do
  extends "api/v2/roles/base"
end

child :permissions do
  extends "api/v2/permissions/base"
end
