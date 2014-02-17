object @smart_proxy

extends "api/v2/smart_proxies/main"

node do |hostgroup|
  partial("api/v2/taxonomies/children_nodes", :object => hostgroup)
end
