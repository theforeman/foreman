require 'foreman/provision'

Foreman::SettingManager.define(:foreman) do
  category(:provisioning, N_('Provisioning')) do
    owner_select = proc do
      [{:name => _("Users"), :class => 'user', :scope => 'visible', :value_method => 'id_and_type', :text_method => 'login'},
       {:name => _("Usergroups"), :class => 'usergroup', :scope => 'visible', :value_method => 'id_and_type', :text_method => 'name'}]
    end

    setting('host_owner',
      type: :string,
      description: N_("Default owner on provisioned hosts, if empty Foreman will use current user"),
      default: nil,
      full_name: N_('Host owner'),
      collection: owner_select,
      include_blank: N_("Select an owner"))
    setting('root_pass',
      type: :string,
      description: N_("Default encrypted root password on provisioned hosts"),
      default: nil,
      full_name: N_('Root password'),
      encrypted: true)
    setting('unattended_url',
      type: :string,
      description: N_("URL hosts will retrieve templates from during build, when it starts with https unattended/userdata controllers cannot be accessed via HTTP"),
      default: "http://#{SETTINGS[:fqdn]}",
      full_name: N_('Unattended URL'))
    setting('safemode_render',
      type: :boolean,
      description: N_("Enable safe mode config templates rendering (recommended)"),
      default: true,
      full_name: N_('Safemode rendering'))
    setting('access_unattended_without_build',
      type: :boolean,
      description: N_("Allow access to unattended URLs without build mode being used"),
      default: false,
      full_name: N_('Access unattended without build'))
    setting('query_local_nameservers',
      type: :boolean,
      description: N_("Foreman will query the locally configured resolver instead of the SOA/NS authorities"),
      default: false,
      full_name: N_('Query local nameservers'))
    setting('token_duration',
      type: :integer,
      description: N_("Time in minutes installation tokens should be valid for, 0 to disable token generation"),
      default: 60 * 6,
      full_name: N_('Installation token lifetime'))
    setting('ssh_timeout',
      type: :integer,
      description: N_("Time in seconds before SSH provisioning times out"),
      default: 60 * 2,
      full_name: N_('SSH timeout'))
    setting('libvirt_default_console_address',
      type: :string,
      description: N_("The IP address that should be used for the console listen address when provisioning new virtual machines via Libvirt"),
      default: "0.0.0.0",
      full_name: N_('Libvirt default console address'))
    setting('update_ip_from_built_request',
      type: :boolean,
      description: N_("Foreman will update the host IP with the IP that made the built request"),
      default: false,
      full_name: N_('Update IP from built request'))
    setting('use_shortname_for_vms',
      type: :boolean,
      description: N_("Foreman will use the short hostname instead of the FQDN for creating new virtual machines"),
      default: false,
      full_name: N_('Use short name for VMs'))
    setting('dns_timeout',
      type: :array,
      description: N_("List of timeouts (in seconds) for DNS lookup attempts such as the dns_lookup macro and DNS record conflict validation"),
      default: [5, 10, 15, 20],
      full_name: N_('DNS timeout'))
    setting('clean_up_failed_deployment',
      type: :boolean,
      description: N_("Foreman will delete virtual machine if provisioning script ends with non zero exit code"),
      default: true,
      full_name: N_('Clean up failed deployment'))
    setting('name_generator_type',
      type: :string,
      description: N_("Random gives unique names, MAC-based are longer but stable (and only works with bare-metal)"),
      default: 'Random-based',
      full_name: N_("Type of name generator"),
      collection: proc { NameGenerator::GENERATOR_TYPES })
    setting('default_pxe_item_global',
      type: :string,
      description: N_("Default PXE menu item in global template - 'local', 'discovery' or custom, use blank for template default"),
      default: nil,
      full_name: N_("Default PXE global template entry"))
    setting('default_pxe_item_local',
      type: :string,
      description: N_("Default PXE menu item in local template - 'local', 'force_local_chain_hd0' or custom, use blank for template default"),
      default: nil,
      full_name: N_("Default PXE local template entry"))
    setting('intermediate_ipxe_script',
      type: :string,
      description: N_('Intermediate iPXE script for unattended installations'),
      default: 'iPXE intermediate script',
      full_name: N_('iPXE intermediate script'),
      collection: proc { Hash[ProvisioningTemplate.unscoped.of_kind(:iPXE).map { |tmpl| [tmpl.name, tmpl.name] }] })
    setting('destroy_vm_on_host_delete',
      type: :boolean,
      description: N_("Destroy associated VM on host delete. When enabled, VMs linked to Hosts will be deleted on Compute Resource. When disabled, VMs are unlinked when the host is deleted, meaning they remain on Compute Resource and can be re-associated or imported back to Foreman again. This does not automatically power off the VM"),
      default: false,
      full_name: N_("Destroy associated VM on host delete"))
    setting('maximum_structured_facts',
      type: :integer,
      description: N_("Maximum amount of keys in structured subtree, statistics stored in foreman::dropped_subtree_facts"),
      default: 100,
      full_name: N_('Maximum structured facts'))
    setting('default_global_registration_item',
      type: :string,
      description: N_("Global Registration template"),
      default: 'Global Registration',
      full_name: N_("Default Global registration template"))
    setting('default_host_init_config_template',
      type: :string,
      description: N_("Default 'Host initial configuration' template, automatically assigned when a new operating system is created"),
      default: 'Linux host_init_config default',
      full_name: N_("Default 'Host initial configuration' template"))
    setting('ct_command',
      type: :array,
      description: N_("Full path to CoreOS transpiler (ct) with arguments as an comma-separated array"),
      default: [which('ct'), '--pretty', '--files-dir', Rails.root.join('config', 'ct').to_s],
      full_name: N_("CoreOS Transpiler Command"))
    setting('fcct_command',
      type: :array,
      description: N_("Full path to Fedora CoreOS transpiler (fcct) with arguments as an comma-separated array"),
      default: [which('fcct'), '--pretty', '--files-dir', Rails.root.join('config', 'ct').to_s],
      full_name: N_("Fedora CoreOS Transpiler Command"))

    # We have following loop twice to keep the historical order.
    # TODO: First resolve the correct order and then optimize this loop.
    Foreman::Provision::PXE_TEMPLATE_KINDS.each do |pxe_kind|
      setting("global_#{pxe_kind}",
        type: :string,
        description: N_("Global default %s template. This template gets deployed to all configured TFTP servers. It will not be affected by upgrades.") % pxe_kind,
        default: Foreman::Provision.global_default_name(pxe_kind),
        full_name: N_("Global default %s template") % pxe_kind,
        collection: proc { Hash[ProvisioningTemplate.unscoped.of_kind(pxe_kind).pluck(:name).map { |name| [name, name] }] },
        validate: :pxe_template_name)
    end
    Foreman::Provision::PXE_TEMPLATE_KINDS.each do |pxe_kind|
      setting("local_boot_#{pxe_kind}",
        type: :string,
        description: N_("Template that will be selected as %s default for local boot.") % pxe_kind,
        default: Foreman::Provision.local_boot_default_name(pxe_kind),
        full_name: N_("Local boot %s template") % pxe_kind,
        collection: proc { Hash[ProvisioningTemplate.unscoped.of_kind(pxe_kind).pluck(:name).map { |name| [name, name] }] },
        validate: :pxe_template_name)
    end
  end
end

Foreman::SettingManager.define(:puppet) do
  category(:provisioning) do
    setting('manage_puppetca',
      type: :boolean,
      description: N_("Foreman will automate certificate signing upon provision of new host"),
      default: true,
      full_name: N_('Manage PuppetCA'))
    setting('use_uuid_for_certificates',
      type: :boolean,
      description: N_("Foreman will use random UUIDs for certificate signing instead of hostnames"),
      default: false,
      full_name: N_('Use UUID for certificates'))
  end
end
