object @smart_proxy

extends "api/v2/smart_proxies/base"

attributes :created_at, :updated_at

child :features do
  attributes :name, :id, :url
end

child :hostnames do
  extends "api/v2/smart_proxies/hostnames"
end
