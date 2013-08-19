object @host

extends "api/v2/hosts/details"

associated_attributes :domain, :architecture, :subnet, :ptable, :medium, :owner, :image, :puppet_proxy, :puppet_ca_proxy

attributes :build, :comment, :disk, :installed_at, :enabled,  :managed, :use_image, :image_file, :uuid, :certname,
           :sp_mac, :sp_ip, :sp_subnet_id, :sp_name
