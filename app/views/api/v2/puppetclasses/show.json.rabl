object @puppetclass

attributes :id, :name, :created_at, :updated_at

child :environments, :object_root => false do
  attributes :id, :name
end

child :hostgroups, :object_root => false do
  attributes :id, :label
end

node do |puppetclass|
  { :smart_variables => partial("api/v2/smart_variables/base", :object => puppetclass.lookup_keys) }
end

node do |puppetclass|
  { :smart_class_parameters => partial("api/v2/smart_class_parameters/base", :object => puppetclass.class_params) }
end

