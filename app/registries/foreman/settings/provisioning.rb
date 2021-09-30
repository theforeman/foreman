Foreman::SettingManager.define(:foreman) do
  category(:provisioning, N_('Provisioning')) do
    # facts which change way too often
    IGNORED_FACTS = [
      'load_averages::*',
      'memory::system::capacity',
      'memory::system::used*',
      'memory::system::available*',
      'memory::swap::capacity',
      'memory::swap::used*',
      'memory::swap::available*',
    ].freeze

    IGNORED_INTERFACES = [
      'lo',
      'en*v*',
      'usb*',
      'vnet*',
      'macvtap*',
      ';vdsmdummy;',
      'veth*',
      'docker*',
      'tap*',
      'qbr*',
      'qvb*',
      'qvo*',
      'qr-*',
      'qg-*',
      'vlinuxbr*',
      'vovsbr*',
      'br-int',
    ].freeze

    unattended_url = "http://#{SETTINGS[:fqdn]}"
    owner_select = [{:name => _("Users"), :class => 'user', :scope => 'visible', :value_method => 'id_and_type', :text_method => 'login'},
                    {:name => _("Usergroups"), :class => 'usergroup', :scope => 'visible', :value_method => 'id_and_type', :text_method => 'name'}]

    setting('host_owner',
      type: :string,
      description: N_("Default owner on provisioned hosts, if empty Foreman will use current user"),
      default: nil,
      full_name: N_('Host owner'),
      collection: proc { owner_select },
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
      default: unattended_url,
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
    setting('manage_puppetca',
      type: :boolean,
      description: N_("Foreman will automate certificate signing upon provision of new host"),
      default: true,
      full_name: N_('Manage PuppetCA'))
    setting('ignore_puppet_facts_for_provisioning',
      type: :boolean,
      description: N_("Stop updating IP address and MAC values from Puppet facts (affects all interfaces)"),
      default: false,
      full_name: N_('Ignore Puppet facts for provisioning'))
    setting('ignored_interface_identifiers',
      type: :array,
      description: N_("Skip creating or updating host network interfaces objects with identifiers matching these values from incoming facts. You can use * wildcard to match identifiers with indexes e.g. macvtap*. The ignored interfaces raw facts will be still stored in the DB, see the 'Exclude pattern' setting for more details."),
      default: IGNORED_INTERFACES,
      full_name: N_('Ignore interfaces with matching identifier'))
    setting('ignore_facts_for_operatingsystem',
      type: :boolean,
      description: N_("Stop updating Operating System from facts"),
      default: false,
      full_name: N_('Ignore facts for operating system'))
    setting('ignore_facts_for_domain',
      type: :boolean,
      description: N_("Stop updating domain values from facts"),
      default: false,
      full_name: N_('Ignore facts for domain'))
    setting('query_local_nameservers',
      type: :boolean,
      description: N_("Foreman will query the locally configured resolver instead of the SOA/NS authorities"),
      default: false,
      full_name: N_('Query local nameservers'))
    setting('token_duration',
      type: :integer,
      description: N_("Time in minutes installation tokens should be valid for, 0 to disable token generation"),
      default: 60 * 6,
      full_name: N_('Token duration'))
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
      description: N_("Default PXE menu item in local template - 'local', 'local_chain_hd0' or custom, use blank for template default"),
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
    setting('excluded_facts',
      type: :array,
      description: N_("Exclude pattern for all types of imported facts (puppet, ansible, rhsm). Those facts won't be stored in foreman's database. You can use * wildcard to match names with indexes e.g. ignore* will filter out ignore, ignore123 as well as a::ignore or even a::ignore123::b"),
      default: IGNORED_INTERFACES + IGNORED_FACTS,
      full_name: N_('Exclude pattern for facts stored in foreman'))
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
      description: N_("Default 'Host initial configuration' template, automatically assigned when new operating system is created"),
      default: 'Linux host_init_config default',
      full_name: N_("Default 'Host initial configuration' template"))

    # We have following loop twice to keep the historical order.
    # TODO: First resolve the correct order and then optimize this loop.
    TemplateKind::PXE.each do |pxe_kind|
      setting("global_#{pxe_kind}",
        type: :string,
        description: N_("Global default %s template. This template gets deployed to all configured TFTP servers. It will not be affected by upgrades.") % pxe_kind,
        default: ProvisioningTemplate.global_default_name(pxe_kind),
        full_name: N_("Global default %s template") % pxe_kind,
        collection: proc { Hash[ProvisioningTemplate.unscoped.of_kind(pxe_kind).map { |tmpl| [tmpl.name, tmpl.name] }] },
        validates: :pxe_template_name)
    end
    TemplateKind::PXE.each do |pxe_kind|
      setting("local_boot_#{pxe_kind}",
        type: :string,
        description: N_("Template that will be selected as %s default for local boot.") % pxe_kind,
        default: ProvisioningTemplate.local_boot_name(pxe_kind),
        full_name: N_("Local boot %s template") % pxe_kind,
        collection: proc { Hash[ProvisioningTemplate.unscoped.of_kind(pxe_kind).map { |tmpl| [tmpl.name, tmpl.name] }] },
        validates: :pxe_template_name)
    end

    validates 'safemode_render', ->(value) { value || Setting[:bmc_credentials_accessible] }, message: N_("Unable to disable safemode_render when bmc_credentials_accessible is disabled")
  end
end
