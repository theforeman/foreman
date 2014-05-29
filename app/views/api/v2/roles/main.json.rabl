object @role

extends "api/v2/roles/base"

attributes :builtin, :created_at, :updated_at

child :permissions do
  extends "api/v2/permissions/base"
end

child :filters do
  extends "api/v2/filters/base"
end
