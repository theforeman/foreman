object @smart_proxy

extends "api/v2/smart_proxies/base"

attributes :created_at, :updated_at

child :smart_proxy_features => :features do
  attributes :capabilities
  glue :feature do
    attributes :name, :id
  end
end
