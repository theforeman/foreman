object @smart_proxy

extends "api/v2/smart_proxies/main"

child :features, :object_root => false do
	attributes :name, :id, :url
end


