object @smart_proxy_pool

extends "api/v2/smart_proxy_pools/main"

child :smart_proxies do
  extends "api/v2/smart_proxies/base"
end

node do |smart_proxy_pool|
  partial("api/v2/taxonomies/children_nodes", :object => smart_proxy_pool)
end
