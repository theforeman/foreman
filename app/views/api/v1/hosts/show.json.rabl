object @host

attributes :name, :id, :ip, :environment_id, :last_report, :updated_at, :created_at, :mac,
           :sp_mac, :sp_ip, :sp_name, :domain_id, :architecture_id, :operatingsystem_id,
           :subnet_id, :sp_subnet_id, :ptable_id, :medium_id, :build,
           :comment, :disk, :installed_at, :model_id, :hostgroup_id, :owner_id, :owner_type,
           :enabled, :puppet_ca_proxy_id, :managed, :use_image, :image_file, :uuid, :compute_resource_id,
           :puppet_proxy_id, :certname, :image_id,
           :last_compile, :last_freshcheck, :serial, :source_file_id, :puppet_status, :root_pass,
           :domain_name, :architecture_name, :operatingsystem_name, :subnet_name, :sp_subnet_name,
           :ptable_name, :medium_name, :model_name, :hostgroup_name, :owner_name,
           :puppet_ca_proxy_name, :compute_resource_name, :puppet_proxy_name, :image_name,
           :source_file_name

if SETTINGS[:organizations_enabled]
  attribute :organization_id, :organization_name
end

if SETTINGS[:locations_enabled]
  attribute :location_id, :location_name
end

child :environment do
  attributes :id, :name
end

child :host_parameters do
  attributes :id, :name, :value, :priority, :is_property, :reference_id, :created_at, :updated_at
end

node do |host|
   { :interfaces => partial("api/v1/interfaces/show", :object => host.interfaces) }
end
