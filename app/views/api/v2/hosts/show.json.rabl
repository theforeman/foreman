object @host

attributes :name, :id, :ip, :environment_id, :last_report, :updated_at, :created_at, :mac,
           :sp_mac, :sp_ip, :sp_name, :domain_id, :architecture_id, :operatingsystem_id,
           :subnet_id, :sp_subnet_id, :ptable_id, :medium_id, :build,
           :comment, :disk, :installed_at, :model_id, :hostgroup_id, :owner_id, :owner_type,
           :enabled, :puppet_ca_proxy_id, :managed, :use_image, :image_file, :uuid, :compute_resource_id,
           :puppet_proxy_id, :certname, :image_id, :created_at, :updated_at,
           :last_compile, :last_freshcheck, :serial, :source_file_id, :puppet_status, :root_pass

if SETTINGS[:organizations_enabled]
  attribute :organization_id
end

if SETTINGS[:locations_enabled]
  attribute :location_id
end

child :environment do
  attributes :id, :name
end

child :host_parameters do
  attributes :id, :name, :value, :priority, :is_property, :reference_id, :created_at, :updated_at
end

node do |host|
   { :interfaces => partial("api/v2/interfaces/show", :object => host.interfaces) }
end
