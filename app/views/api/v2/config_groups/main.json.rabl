object @config_group

extends "api/v2/config_groups/base"

attributes :created_at, :updated_at

child :puppetclasses do
  extends "api/v2/puppetclasses/base"
end
