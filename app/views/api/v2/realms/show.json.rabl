object @realm
extends "api/v2/realms/main"

node do |realm|
  partial("api/v2/taxonomies/children_nodes", :object => realm)
end
