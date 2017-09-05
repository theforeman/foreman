object @hostgroup

extends "api/v2/hostgroups/base"
extends "api/v2/smart_proxies/children_nodes"

attributes :subnet_id, :subnet_name, :operatingsystem_id, :operatingsystem_name, :domain_id, :domain_name,
           :environment_id, :environment_name, :compute_profile_id, :compute_profile_name, :ancestry, :parent_id, :parent_name,
           :ptable_id, :ptable_name, :medium_id, :medium_name, :pxe_loader,
           :subnet6_id, :subnet6_name,
           :architecture_id, :architecture_name, :realm_id, :realm_name, :created_at, :updated_at

if @parameters
  node do |hostgroup|
    { :parameters => partial("api/v2/parameters/index", :object => hostgroup.group_parameters.authorized) }
  end
end
