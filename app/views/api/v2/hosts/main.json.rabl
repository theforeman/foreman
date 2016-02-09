object @host

extends "api/v2/hosts/base"

# we need to cache results with @last_reports, rabl can't pass custom parameters to attriute methods
@object.global_status_label(:last_reports => @last_reports)
@object.configuration_status(:last_reports => @last_reports)
@object.configuration_status_label(:last_reports => @last_reports)

attributes :ip, :environment_id, :environment_name, :last_report, :mac, :realm_id, :realm_name,
           :sp_mac, :sp_ip, :sp_name, :domain_id, :domain_name, :architecture_id, :architecture_name, :operatingsystem_id, :operatingsystem_name,
           :subnet_id, :subnet_name, :sp_subnet_id, :ptable_id, :ptable_name, :medium_id, :medium_name, :build,
           :comment, :disk, :installed_at, :model_id, :hostgroup_id, :hostgroup_name, :owner_id, :owner_type,
           :enabled, :puppet_ca_proxy_id, :managed, :use_image, :image_file, :uuid, :compute_resource_id, :compute_resource_name,
           :compute_profile_id, :compute_profile_name, :capabilities, :provision_method,
           :puppet_proxy_id, :certname, :image_id, :image_name, :created_at, :updated_at,
           :last_compile, :global_status, :global_status_label
attributes :organization_id, :organization_name if SETTINGS[:organizations_enabled]
attributes :location_id, :location_name         if SETTINGS[:locations_enabled]

# to avoid deprecation warning on puppet_status method
attributes :configuration_status => :puppet_status

# to avoid renaming model_name to match accessors
attributes :hardware_model_name => :model_name

HostStatus.status_registry.each do |status_class|
  attributes "#{status_class.humanized_name}_status", "#{status_class.humanized_name}_status_label", :if => @object.get_status(status_class).relevant?
end

@object.facets_with_definitions.each do |_facet, definition|
  node do
    partial(definition.api_list_view, :object => @object) if definition.api_list_view
  end
end
