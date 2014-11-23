module Foreman
  module PermittedAttributes
    ATTRIBUTES = [
      :location_organization_attributes,
      :operatingsystem_ids_attributes,
      :architecture_attributes,
      :auth_source_ldap_attributes,
      :operatingsystem_attributes,
      :os_parameters_attributes,
      :os_default_templates_attributes,
      :smart_proxy_attributes,
      :bookmark_attributes,
      :common_parameter_attributes,
      :user_self_attributes,
      :user_attributes,
      :user_admin_attributes,
      :compute_attribute_attributes,
      :nics_attributes,
      :compute_profile_attributes,
      :compute_resource_attributes,
      :config_group_attributes,
      :config_template_attributes,
      :template_combinations_attributes,
      :parameter_attributes, ## serves all smart params
      :domain_attributes,
      :environment_attributes,
      :filter_attributes,
      :hostgroup_attributes,
      :host_attributes,
      :image_attributes,
      :lookup_key_attributes,
      :lookup_value_attributes,
      :medium_attributes,
      :model_attributes,
      :ptable_attributes,
      :puppetclass_attributes,
      :class_params_attributes,
      :realm_attributes,
      :role_attributes,
      :setting_attributes,
      :subnet_attributes,
      :usergroup_attributes,
      :trend_attributes,
      :external_usergroups_attributes,
      :vm_attrs_libvirt_attributes,
      :vm_attrs_ec2_attributes,
      :vm_attrs_gce_attributes,
      :vm_attrs_openstack_attributes,
      :vm_attrs_ovirt_attributes,
      :vm_attrs_rackspace_attributes,
      :vm_attrs_vmware_attributes
    ]

    mattr_reader(*ATTRIBUTES)

    @@location_organization_attributes = [
      :location_ids => [],
      :organization_ids => []
    ]

    @@architecture_attributes = [
      :name,
      {:operatingsystem_ids => []}
    ]

    @@auth_source_ldap_attributes = [
      :name, :host, :tls, :port, :server_type, :account,
      :account_password, :base_dn, :groups_base, :ldap_filter,
      :onthefly_register, :attr_login, :attr_firstname, :attr_lastname, :attr_mail, :attr_photo
    ]

    @@operatingsystem_attributes = [
      :name, :major, :minor, :description, :family,
      :release_name, :password_hash, {:architecture_ids => [],
      :ptable_ids => [], :medium_ids => []}
    ]

    @@os_parameters_attributes = [
      :name, :value, :hidden_value, :id, :_destroy, :nested
    ]

    @@os_default_templates_attributes = [
      :config_template_id, :template_kind_id, :id
    ]
    @@smart_proxy_attributes = [
      :name, :url, *@@location_organization_attributes
    ]

    @@bookmark_attributes = [
      :name, :query, :public, :controller
    ]

    @@common_parameter_attributes = [
      :name, :value, :hidden_value
    ]

    @@user_self_attributes = [
      :password_confirmation,
      :password,
      :mail,
      :firstname,
      :lastname,
      :locale,
      :default_organization_id,
      :default_location_id,
      :mail_enabled,
      :mail_notification_ids => [],
      :user_mail_notifications_attributes => [:mail_notification_id, :interval, :id, :_destroy]
    ]

    @@user_attributes = [
      :login,
      :auth_source_id,
      {:role_ids => [],
      :hostgroup_ids => []},
      *(@@user_self_attributes +
        @@location_organization_attributes)
    ]

    @@user_admin_attributes = [
      :admin
    ]

    @@compute_attribute_attributes = [
      :compute_profile_id, :compute_resource_id, :name
    ]

    @@nics_attributes = [
      :type, :_delete, :bridge, :model
    ]

    @@compute_profile_attributes = [
      :name
    ]

    @@compute_resource_attributes = [
      :name, :provider, :description,
      :url, :display_type, :set_console_password, :zone, :project,
      :user, :password, :uuid, :ovirt_quota, :public_key,
      :region, :server, :pubkey_hash, :tenant, :project, :email, :key_path,
      *@@location_organization_attributes

    ]

    @@config_group_attributes = [
      :name, {:puppetclass_ids => []}
    ]

    @@config_template_attributes = [
      :name, :template, :audit_comment, :snippet, :template_kind_id, {:operatingsystem_ids => []}
    ]

    @@template_combinations_attributes = [
      :hostgroup_id, :environment_id, :_destroy, :id
    ]

    @@domain_attributes = [
      :name, :fullname, :dns_id, *@@location_organization_attributes
    ]

    @@parameter_attributes = [
      :name, :value, :hidden_value, :_destroy, :id, :nested
    ]

    @@environment_attributes = [
      :name, *@@location_organization_attributes
    ]

    @@filter_attributes = [
      :role_id, :resource_type, :unlimited, :search, {:permission_ids => []}, *@@location_organization_attributes
    ]

    @@hostgroup_attributes = [
      :parent_id, :name, :environment_id, :compute_profile_id,
      :puppet_ca_proxy_id, :puppet_proxy_id, :domain_id, :subnet_id,
      :realm_id, :architecture_id, :operatingsystem_id, :medium_id,
      :ptable_id, :root_pass, {:config_group_ids => [], :puppetclass_ids => []},
      *@@location_organization_attributes
    ]

    @@host_attributes = [
      :name, :organization_id, :location_id, :hostgroup_id,
      :compute_resource_id, :compute_profile_id, :environment_id,
      :puppet_ca_proxy_id, :puppet_proxy_id, :managed, :progress_report_id,
      :type, :domain_id, :realm_id, :start, :mac, :subnet_id, :ip, :architecture_id,
      :operatingsystem_id, :provision_method, :build, :medium_id, :ptable_id, :disk,
      :root_pass, :is_owned_by, :enabled, :model_id, :comment, :overwrite, :capabilities,
      :rpovider, {:config_group_ids => [], :puppetclass_ids => []}
    ]

    @@image_attributes = [
      :name, :compute_resource_id, :operatingsystem_id, :architecture_id, :username, :password, :uuid,
        :user_data, :iam_role

    ]

    @@lookup_key_attributes = [
      :key, :description, :override, :key_type, :default_value, :required, :validator_type, :use_puppet_default,
      :validator_rule, :path, :_destroy, :id, :puppetclass_id, {:lookup_values_attributes => [:id, :value, :match, :use_puppet_default, :_destroy]}
    ]

    @@class_params_attributes = [
      :id, :_destroy, :key, :description, :override, :key_type, :default_value, :required, :validator_type,
      :validator_rule, :path, {:lookup_values_attributes => [:_destroy, :match, :value, :id]}
    ]

    @@lookup_value_attributes = [
      :match, :value, :lookup_key_id, :id, :_destroy
    ]

    @@medium_attributes = [
      :name, :path, :media_path, :config_path, :image_path, :os_family, *@@location_organization_attributes
    ]

    @@model_attributes = [
      :name, :hardware_model, :vendor_class, :info
    ]

    @@ptable_attributes = [
      :name, :layout, :os_family
    ]

    @@puppetclass_attributes = [
      :name, {:hostgroup_ids => []}
    ]

    @@realm_attributes = [
      :name, :realm_type, :realm_proxy_id, *@@location_organization_attributes
    ]

    @@role_attributes = [
      :name
    ]

    @@setting_attributes = [
      :value
    ]

    @@subnet_attributes = [
      :name, :network, :mask, :gateway, :dns_primary, :dns_secondary, :ipam, :from, :to,
      :vlanid, :boot_mode, :dhcp_id, :tftp_id, :dns_id, {:domain_ids => []},
      *@@location_organization_attributes
    ]

    @@usergroup_attributes = [
      :name, :admin, {:user_ids => [], :role_ids => [], :usergroup_ids => []}
    ]

    @@trend_attributes = [
      :name, :trendable_type, :trendable_id
    ]

    @@external_usergroups_attributes = [
      :_destroy, :name, :auth_source_id
    ]

    @@vm_attrs_libvirt_attributes = [
      :cpus, :memory, :image_id, :start,
      {:nics_attributes => [:type, :_delete, :bridge, :model, :network]},
      {:volumes_attributes => [:pool_name, :capacity, :allocation, :format_type, :_delete]}
    ]

    @@vm_attrs_ec2_attributes = [
      :flavor_id, :image_id, :availability_zone, :subnet_id, :managed_ip, {:security_group_ids => []}
    ]

    @@vm_attrs_gce_attributes = [
      :machine_type, :image_id, :network, :external_ip
    ]

    @@vm_attrs_openstack_attributes = [
      :name, :flavor_ref, :image_ref, :tenant_id, :security_groups, :network, {:nics => []}
    ]

    @@vm_attrs_ovirt_attributes = [
      :name, :cluster, :template, :cores, :memory, {:interfaces => [:name, :network]}, {:volumes => [:size_gb, :storage_domain, :id, :preallocate, :bootable]}
    ]

    @@vm_attrs_rackspace_attributes = [
      :flavor_id, :image_id
    ]

    @@vm_attrs_vmware_attributes = [
      :name, :cpus, :corespersocket, :memory_mb, :cluster, :path, :guest_id, :hardware_version,
      {:interface => [:type, :network]}, {:volumes => [:datastore, :name, :size_gb, :thin, :eager_zero]}
    ]
  end
end
