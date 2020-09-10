object @audit

extends "api/v2/audits/main"

node do |audit|
  partial("api/v2/taxonomies/children_nodes", :object => audit)
end
