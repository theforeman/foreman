object @hostname

extends "api/v2/hostnames/main"

child :smart_proxies do
  extends "api/v2/smart_proxies/base"
end

node do |hostname|
  partial("api/v2/taxonomies/children_nodes", :object => hostname)
end
