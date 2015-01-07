object @deployment

extends 'api/v2/deployments/main'

node do |deployment|
  partial("api/v2/taxonomies/children_nodes", :object => deployment)
end
