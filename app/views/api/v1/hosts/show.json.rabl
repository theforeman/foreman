object @host

attributes :name, :id, :ip, :environment, :last_report, :updated_at, :created_at, :mac,
           :sp_mac, :sp_ip, :sp_name, :domain_id, :architecture_id, :operatingsystem_id,
           :environment_id, :subnet_id, :sp_subnet_id, :ptable_id, :medium_id, :build,
           :comment, :disk, :installed_at, :model_id, :hostgroup_id, :owner_id, :owner_type,
           :enabled, :puppet_ca_proxy_id, :managed, :use_image, :image_file, :uuid, :compute_resource_id,
           :puppet_proxy_id, :certname, :image_id

child :host_parameters do
  attributes :name, :value
end
