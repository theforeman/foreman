object @http_proxy

extends "api/v2/http_proxies/main"

child :locations => :locations do
  attributes :id, :name, :title
end

child :organizations => :organizations do
  attributes :id, :name, :title
end
