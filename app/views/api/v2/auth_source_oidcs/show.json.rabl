object @auth_source_oidc

extends 'api/v2/auth_source_oidcs/main'

node do |auth_source_oidc|
  partial('api/v2/taxonomies/children_nodes', :object => auth_source_oidc)
end
