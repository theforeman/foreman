object @ptable

extends "api/v2/ptables/main"

attributes :layout, :locked

child :operatingsystems do
  extends "api/v2/operatingsystems/base"
end

node do |ptable|
  partial("api/v2/taxonomies/children_nodes", :object => ptable)
end
