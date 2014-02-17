object @compute_resource

extends "api/v2/compute_resources/main"

child :images, :object_root => false do
  extends "api/v2/images/base"
end

node do |compute_resource|
   partial("api/v2/taxonomies/children_nodes", :object => compute_resource)
end
