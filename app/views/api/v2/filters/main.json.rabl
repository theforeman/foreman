object @filter

extends "api/v2/filters/base"

attributes :search, :resource_type, :resource_type_label, :unlimited?, :created_at, :updated_at, :override?

child :role do
  extends "api/v2/roles/base"
end

child :permissions do
  extends "api/v2/permissions/base"
end
