object @smart_proxy

extends "api/v2/smart_proxies/main"

node do |hostgroup|
  partial("api/v2/taxonomies/children_nodes", :object => hostgroup)
end

if @version
  node(:version) { @smart_proxy.statuses[:version].version['version'] }
end

child :smart_proxy_features => :features do
  glue :feature do
    attributes :name, :id
    if @version
      node(:version) do |feature|
        @smart_proxy.statuses[:version].version['modules'][feature["name"].downcase]
      end
    end
  end
end
