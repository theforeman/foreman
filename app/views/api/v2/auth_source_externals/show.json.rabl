object @auth_source_external

extends "api/v2/auth_source_externals/main"

node do |auth_source_external|
  partial("api/v2/taxonomies/children_nodes", :object => auth_source_external)
end

child :external_usergroups do
  extends "api/v2/external_usergroups/base"
end
