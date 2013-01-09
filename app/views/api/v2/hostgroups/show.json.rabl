object @hostgroup

attributes :id, :name, :label, :updated_at, :created_at

child :group_parameters => :parameters do
	attributes :name, :value
end

child :all_puppetclasses do
	attributes :name, :id
end

glue :domain do
  attributes :name => :domain_name
end

glue :subnet do
  attributes :name => :subnet_name, :id => :subnet_id
end

glue :operatingsystem do
  attributes :fullname => :operatingsystem_name, :id => :operatingsystem_id
end

glue :environment do
  attributes :name => :environment_name
end