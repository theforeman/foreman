object @role

extends "api/v2/roles/main"

child :filters => :filters do
  extends "api/v2/filters/base"
end
