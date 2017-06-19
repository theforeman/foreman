class PermissionsList
  class << self
    def permissions
      [
        %w[Architecture view_architectures],
        %w[Architecture create_architectures],
        %w[Architecture edit_architectures],
        %w[Architecture destroy_architectures],
        %w[Audit view_audit_logs],
        %w[AuthSourceLdap view_authenticators],
        %w[AuthSourceLdap create_authenticators],
        %w[AuthSourceLdap edit_authenticators],
        %w[AuthSourceLdap destroy_authenticators],
        %w[Bookmark view_bookmarks],
        %w[Bookmark create_bookmarks],
        %w[Bookmark edit_bookmarks],
        %w[Bookmark destroy_bookmarks],
        %w[ComputeProfile view_compute_profiles],
        %w[ComputeProfile create_compute_profiles],
        %w[ComputeProfile edit_compute_profiles],
        %w[ComputeProfile destroy_compute_profiles],
        %w[ComputeResource view_compute_resources],
        %w[ComputeResource create_compute_resources],
        %w[ComputeResource edit_compute_resources],
        %w[ComputeResource destroy_compute_resources],
        %w[ComputeResource view_compute_resources_vms],
        %w[ComputeResource create_compute_resources_vms],
        %w[ComputeResource edit_compute_resources_vms],
        %w[ComputeResource destroy_compute_resources_vms],
        %w[ComputeResource power_compute_resources_vms],
        %w[ComputeResource console_compute_resources_vms],
        %w[ConfigReport view_config_reports],
        %w[ConfigReport destroy_config_reports],
        %w[ConfigReport upload_config_reports],
        %w[ConfigGroup view_config_groups],
        %w[ConfigGroup create_config_groups],
        %w[ConfigGroup edit_config_groups],
        %w[ConfigGroup destroy_config_groups],
        [nil, 'access_dashboard'],
        %w[Domain view_domains],
        %w[Domain create_domains],
        %w[Domain edit_domains],
        %w[Domain destroy_domains],
        %w[Environment view_environments],
        %w[Environment create_environments],
        %w[Environment edit_environments],
        %w[Environment destroy_environments],
        %w[Environment import_environments],
        %w[ExternalUsergroup view_external_usergroups],
        %w[ExternalUsergroup create_external_usergroups],
        %w[ExternalUsergroup edit_external_usergroups],
        %w[ExternalUsergroup destroy_external_usergroups],
        %w[FactValue view_facts],
        %w[FactValue upload_facts],
        %w[Filter view_filters],
        %w[Filter create_filters],
        %w[Filter edit_filters],
        %w[Filter destroy_filters],
        %w[HostClass edit_classes],
        %w[Hostgroup view_hostgroups],
        %w[Hostgroup create_hostgroups],
        %w[Hostgroup edit_hostgroups],
        %w[Hostgroup destroy_hostgroups],
        %w[Host view_hosts],
        %w[Host create_hosts],
        %w[Host edit_hosts],
        %w[Host destroy_hosts],
        %w[Host build_hosts],
        %w[Host power_hosts],
        %w[Host console_hosts],
        %w[Host ipmi_boot_hosts],
        %w[Host puppetrun_hosts],
        %w[Image view_images],
        %w[Image create_images],
        %w[Image edit_images],
        %w[Image destroy_images],
        %w[KeyPair view_keypairs],
        %w[KeyPair destroy_keypairs],
        %w[Location view_locations],
        %w[Location create_locations],
        %w[Location edit_locations],
        %w[Location destroy_locations],
        %w[Location assign_locations],
        %w[VariableLookupKey view_external_variables],
        %w[VariableLookupKey create_external_variables],
        %w[VariableLookupKey edit_external_variables],
        %w[VariableLookupKey destroy_external_variables],
        %w[PuppetclassLookupKey view_external_parameters],
        %w[PuppetclassLookupKey create_external_parameters],
        %w[PuppetclassLookupKey edit_external_parameters],
        %w[PuppetclassLookupKey destroy_external_parameters],
        %w[MailNotification view_mail_notifications],
        %w[Medium view_media],
        %w[Medium create_media],
        %w[Medium edit_media],
        %w[Medium destroy_media],
        %w[Model view_models],
        %w[Model create_models],
        %w[Model edit_models],
        %w[Model destroy_models],
        %w[Operatingsystem view_operatingsystems],
        %w[Operatingsystem create_operatingsystems],
        %w[Operatingsystem edit_operatingsystems],
        %w[Operatingsystem destroy_operatingsystems],
        %w[Organization view_organizations],
        %w[Organization create_organizations],
        %w[Organization edit_organizations],
        %w[Organization destroy_organizations],
        %w[Organization assign_organizations],
        %w[Parameter view_params],
        %w[Parameter create_params],
        %w[Parameter edit_params],
        %w[Parameter destroy_params],
        %w[Ptable view_ptables],
        %w[Ptable create_ptables],
        %w[Ptable edit_ptables],
        %w[Ptable destroy_ptables],
        %w[Ptable lock_ptables],
        %w[ProvisioningTemplate view_provisioning_templates],
        %w[ProvisioningTemplate create_provisioning_templates],
        %w[ProvisioningTemplate edit_provisioning_templates],
        %w[ProvisioningTemplate destroy_provisioning_templates],
        %w[ProvisioningTemplate deploy_provisioning_templates],
        %w[ProvisioningTemplate lock_provisioning_templates],
        [nil, 'view_plugins'],
        %w[Puppetclass view_puppetclasses],
        %w[Puppetclass create_puppetclasses],
        %w[Puppetclass edit_puppetclasses],
        %w[Puppetclass destroy_puppetclasses],
        %w[Puppetclass import_puppetclasses],
        %w[Realm view_realms],
        %w[Realm create_realms],
        %w[Realm edit_realms],
        %w[Realm destroy_realms],
        %w[Role view_roles],
        %w[Role create_roles],
        %w[Role edit_roles],
        %w[Role destroy_roles],
        %w[SmartProxy view_smart_proxies],
        %w[SmartProxy create_smart_proxies],
        %w[SmartProxy edit_smart_proxies],
        %w[SmartProxy destroy_smart_proxies],
        %w[SmartProxy view_smart_proxies_autosign],
        %w[SmartProxy create_smart_proxies_autosign],
        %w[SmartProxy destroy_smart_proxies_autosign],
        %w[SmartProxy view_smart_proxies_puppetca],
        %w[SmartProxy edit_smart_proxies_puppetca],
        %w[SmartProxy destroy_smart_proxies_puppetca],
        %w[SshKey view_ssh_keys],
        %w[SshKey create_ssh_keys],
        %w[SshKey destroy_ssh_keys],
        [nil, 'view_statistics'],
        %w[Subnet view_subnets],
        %w[Subnet create_subnets],
        %w[Subnet edit_subnets],
        %w[Subnet destroy_subnets],
        %w[Subnet import_subnets],
        [nil, 'view_tasks'],
        %w[Trend view_trends],
        %w[Trend create_trends],
        %w[Trend edit_trends],
        %w[Trend destroy_trends],
        %w[Trend update_trends],
        %w[Usergroup view_usergroups],
        %w[Usergroup create_usergroups],
        %w[Usergroup edit_usergroups],
        %w[Usergroup destroy_usergroups],
        %w[User view_users],
        %w[User create_users],
        %w[User edit_users],
        %w[User destroy_users]
      ]
    end
  end
end
