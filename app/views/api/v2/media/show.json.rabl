object @medium

extends "api/v2/media/main"

child :operatingsystems do
  extends "api/v2/operatingsystems/base"
end

node do |medium|
  partial("api/v2/taxonomies/children_nodes", :object => medium)
end
