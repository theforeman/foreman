object @filter

extends "api/v2/filters/base"

attributes :search, :resource_type_label, :created_at, :updated_at

child :role do
  extends "api/v2/roles/base"
  node do |role|
    partial("api/v2/taxonomies/children_nodes", :object => role)
  end
end

child :permissions do
  extends "api/v2/permissions/base"
end
