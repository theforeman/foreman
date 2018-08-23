object @host

extends "api/v2/hosts/main"

child :interfaces => :interfaces do
  extends "api/v2/interfaces/main"
end

child :puppetclasses do
  extends "api/v2/puppetclasses/base"
end

node do |host|
  { :all_puppetclasses => partial("api/v2/puppetclasses/base", :object => host.all_puppetclasses) }
end

child :config_groups do
  extends "api/v2/config_groups/main"
end

root_object.facets_with_definitions.each do |_facet, definition|
  node do
    partial(definition.api_single_view, :object => root_object) if definition.api_single_view
  end
end

node :permissions do |host|
  authorizer = Authorizer.new(User.current)
  Permission.where(:resource_type => "Host").all.each_with_object({}) do |permission, hash|
    hash[permission.name] = authorizer.can?(permission.name, host, false)
  end
end
