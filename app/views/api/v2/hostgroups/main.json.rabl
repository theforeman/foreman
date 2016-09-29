object @hostgroup

extends "api/v2/hostgroups/base"

attributes :subnet_id, :subnet_name, :operatingsystem_id, :operatingsystem_name, :domain_id, :domain_name,
           :environment_id, :environment_name, :compute_profile_id, :compute_profile_name, :ancestry, :parent_id, :parent_name,
           :puppet_proxy_id, :puppet_proxy_name, :puppet_ca_proxy_id, :puppet_ca_proxy_name,
           :ptable_id, :ptable_name, :medium_id, :medium_name,
           :architecture_id, :architecture_name, :realm_id, :realm_name, :created_at, :updated_at
