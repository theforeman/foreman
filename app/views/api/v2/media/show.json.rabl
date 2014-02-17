object @medium

extends "api/v2/media/main"

child :operatingsystems, :object_root => false do
  extends "api/v2/operatingsystems/base"
end

node do |medium|
   partial("api/v2/taxonomies/children_nodes", :object => medium)
end
