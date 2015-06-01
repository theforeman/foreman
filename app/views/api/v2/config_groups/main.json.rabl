object @config_group

extends "api/v2/config_groups/base"

attributes :created_at, :updated_at

child :puppetclasses do
  extends "api/v2/puppetclasses/base"
end
node do |config_group|
  partial("api/v2/taxonomies/children_nodes", :object => config_group)
end
