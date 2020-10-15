object @smart_class_parameter

extends "api/v2/lookup_keys/main"

node :puppetclass_id do |lk|
  lk.param_class.id
end

node :puppetclass_name do |lk|
  lk.param_class.name
end
