object @smart_proxy

extends "api/v2/smart_proxies/base"

attributes :created_at, :updated_at, :hosts_count

child :smart_proxy_features => :features do
  attributes :capabilities
  glue :feature do
    attributes :name, :id
  end
end

if @status
  node(:status) { |smart_proxy| smart_proxy.ping ? Ping::STATUS_OK : Ping::STATUS_FAIL }
end
