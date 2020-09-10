object @host

extends "api/v2/hosts/base"
extends "api/v2/smart_proxies/children_nodes"

# we need to cache results with @last_reports, rabl can't pass custom parameters to attriute methods
@object.global_status_label(:last_reports => @last_reports)
@object.configuration_status(:last_reports => @last_reports)
@object.configuration_status_label(:last_reports => @last_reports)

attributes :ip, :ip6, :environment_id, :environment_name, :last_report, :mac, :realm_id, :realm_name,
  :sp_mac, :sp_ip, :sp_name, :domain_id, :domain_name, :architecture_id, :architecture_name, :operatingsystem_id, :operatingsystem_name,
  :subnet_id, :subnet_name, :subnet6_id, :subnet6_name, :sp_subnet_id, :ptable_id, :ptable_name, :medium_id, :medium_name, :pxe_loader,
  :build, :comment, :disk, :installed_at, :model_id, :hostgroup_id, :owner_id, :owner_name, :owner_type,
  :enabled, :managed, :use_image, :image_file, :uuid,
  :compute_resource_id, :compute_resource_name,
  :compute_profile_id, :compute_profile_name, :capabilities, :provision_method,
  :certname, :image_id, :image_name, :created_at, :updated_at,
  :last_compile, :global_status, :global_status_label, :uptime_seconds
attributes :organization_id, :organization_name
attributes :location_id, :location_name

# for compatibility, :puppet_status was moved to host statuses
attributes :configuration_status => :puppet_status

# to avoid renaming model_name to match accessors
attributes :hardware_model_name => :model_name

HostStatus.status_registry.each do |status_class|
  attributes "#{status_class.humanized_name}_status", "#{status_class.humanized_name}_status_label", :if => @object.get_status(status_class).relevant?
end

# display the token, if it hasn't expired
node(:token, :if => ->(h) { h.token && !h.token_expired? }) { |host| host.token.value }

node :hostgroup_name do |host|
  host.hostgroup.name if host.hostgroup.present?
end

node :hostgroup_title do |host|
  host.hostgroup.title if host.hostgroup.present?
end

if @parameters
  node do |host|
    { :parameters => partial("api/v2/parameters/index", :object => host.host_parameters.authorized(:view_params)) }
  end
end

if @all_parameters
  node do |host|
    { :all_parameters => partial("api/v2/parameters/index", :object => host.host_params_objects) }
  end
end

@object.facets_with_definitions.each do |_facet, definition|
  node do
    partial(definition.api_list_view, :object => @object) if definition.api_list_view
  end
end
