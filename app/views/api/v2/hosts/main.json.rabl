object @host

extends "api/v2/hosts/base"

attributes :ip, :environment_id, :environment_name, :last_report, :mac,
           :sp_mac, :sp_ip, :sp_name, :domain_id, :domain_name, :architecture_id, :architecture_name, :operatingsystem_id, :operatingsystem_name,
           :subnet_id, :subnet_name, :sp_subnet_id, :ptable_id, :ptable_name, :medium_id, :medium_name, :build,
           :comment, :disk, :installed_at, :model_id, :model_name, :hostgroup_id, :hostgroup_name, :owner_id, :owner_type,
           :enabled, :puppet_ca_proxy_id, :managed, :use_image, :image_file, :uuid, :compute_resource_id, :compute_resource_name,
           :puppet_proxy_id, :certname, :image_id, :image_name, :created_at, :updated_at,
           :last_compile, :last_freshcheck, :serial, :source_file_id, :puppet_status

if SETTINGS[:organizations_enabled]
  attributes :organization_id, :organization_name
end

if SETTINGS[:locations_enabled]
  attributes :location_id, :location_name
end
