class Setting::Provisioning < Setting
  def self.default_global_labels
    TemplateKind::PXE.map do |pxe_kind|
      "global_#{pxe_kind}"
    end
  end

  def self.local_boot_labels
    TemplateKind::PXE.map do |pxe_kind|
      "local_boot_#{pxe_kind}"
    end
  end

  Setting::BLANK_ATTRS.push(*(default_global_labels + local_boot_labels))
  validates :value, :pxe_template_name => true, :if => proc { |s| s.class.default_global_labels.include?(s.name) }

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

  def self.default_settings
    fqdn = SETTINGS[:fqdn]
    unattended_url = "http://#{fqdn}"
    select = [{:name => _("Users"), :class => 'user', :scope => 'visible', :value_method => 'id_and_type', :text_method => 'login'},
              {:name => _("Usergroups"), :class => 'usergroup', :scope => 'visible', :value_method => 'id_and_type', :text_method => 'name'}]

    [
      set('host_owner', N_("Default owner on provisioned hosts, if empty Foreman will use current user"), nil, N_('Host owner'), nil, {:collection => proc { select }, :include_blank => _("Select an owner")}),
      set('root_pass', N_("Default encrypted root password on provisioned hosts"), nil, N_('Root password'), nil, {:encrypted => true}),
      set('unattended_url', N_("URL hosts will retrieve templates from during build, when it starts with https unattended/userdata controllers cannot be accessed via HTTP"), unattended_url, N_('Unattended URL')),
      set('safemode_render', N_("Enable safe mode config templates rendering (recommended)"), true, N_('Safemode rendering')),
      set('access_unattended_without_build', N_("Allow access to unattended URLs without build mode being used"), false, N_('Access unattended without build')),
      set('manage_puppetca', N_("Foreman will automate certificate signing upon provision of new host"), true, N_('Manage PuppetCA')),
      set('ignore_puppet_facts_for_provisioning', N_("Stop updating IP address and MAC values from Puppet facts (affects all interfaces)"), false, N_('Ignore Puppet facts for provisioning')),
      set('ignored_interface_identifiers', N_("Ignore interfaces that match these values during facts importing, you can use * wildcard to match names with indexes e.g. macvtap*"), IGNORED_INTERFACES, N_('Ignore interfaces with matching identifier')),
      set('ignore_facts_for_operatingsystem', N_("Stop updating Operating System from facts"), false, N_('Ignore facts for operating system')),
      set('ignore_facts_for_domain', N_("Stop updating domain values from facts"), false, N_('Ignore facts for domain')),
      set('query_local_nameservers', N_("Foreman will query the locally configured resolver instead of the SOA/NS authorities"), false, N_('Query local nameservers')),
      set('remote_addr', N_("If Foreman is running behind Passenger or a remote load balancer, the IP should be set here. This is a regular expression, so it can support several load balancers, i.e: (10.0.0.1|127.0.0.1)"), "127.0.0.1", N_('Remote address')),
      set('token_duration', N_("Time in minutes installation tokens should be valid for, 0 to disable token generation"), 60 * 6, N_('Token duration')),
      set('ssh_timeout', N_("Time in seconds before SSH provisioning times out"), 60 * 2, N_('SSH timeout')),
      set('libvirt_default_console_address', N_("The IP address that should be used for the console listen address when provisioning new virtual machines via Libvirt"), "0.0.0.0", N_('Libvirt default console address')),
      set('update_ip_from_built_request', N_("Foreman will update the host IP with the IP that made the built request"), false, N_('Update IP from built request')),
      set('use_shortname_for_vms', N_("Foreman will use the short hostname instead of the FQDN for creating new virtual machines"), false, N_('Use short name for VMs')),
      set('dns_timeout', N_("List of timeouts (in seconds) for DNS lookup attempts such as the dns_lookup macro and DNS record conflict validation"), [5, 10, 15, 20], N_('DNS timeout')),
      set('clean_up_failed_deployment', N_("Foreman will delete virtual machine if provisioning script ends with non zero exit code"), true, N_('Clean up failed deployment')),
      set('name_generator_type', N_("Random gives unique names, MAC-based are longer but stable (and only works with bare-metal)"), 'Random-based', N_("Type of name generator"), nil, {:collection => proc { NameGenerator::GENERATOR_TYPES } }),
      set('default_pxe_item_global', N_("Default PXE menu item in global template - 'local', 'discovery' or custom, use blank for template default"), nil, N_("Default PXE global template entry")),
      set('default_pxe_item_local', N_("Default PXE menu item in local template - 'local', 'local_chain_hd0' or custom, use blank for template default"), nil, N_("Default PXE local template entry")),
      set('intermediate_ipxe_script', N_('Intermediate iPXE script for unattended installations'), 'iPXE intermediate script', N_('iPXE intermediate script'), nil, { :collection => proc { Hash[ProvisioningTemplate.unscoped.of_kind(:iPXE).map { |tmpl| [tmpl.name, tmpl.name] }] } }),
      set(
        'destroy_vm_on_host_delete',
        N_("Destroy associated VM on host delete. When enabled, VMs linked to Hosts will be deleted on Compute Resource. When disabled, VMs are unlinked when the host is deleted, meaning they remain on Compute Resource and can be re-associated or imported back to Foreman again. This does not automatically power off the VM"),
        false,
        N_("Destroy associated VM on host delete")
      ),
      set(
        'excluded_facts',
        N_("Exclude pattern for all types of imported facts (puppet, ansible, rhsm). Those facts won't be stored in foreman's database. You can use * wildcard to match names with indexes e.g. ignore* will filter out ignore, ignore123 as well as a::ignore or even a::ignore123::b"),
        default_excluded_facts,
        N_('Exclude pattern for facts stored in foreman')
      ),
      set('maximum_structured_facts', N_("Maximum amount of keys in structured subtree, statistics stored in foreman::dropped_subtree_facts"), 100, N_('Maximum structured facts')),
      set('default_global_registration_item', N_("Global Registration template"), 'Global Registration', N_("Default Global registration template")),
    ] + default_global_templates + default_local_boot_templates
  end

  def self.humanized_category
    N_('Provisioning')
  end

  def validate_safemode_render(record)
    if !record.value && !Setting[:bmc_credentials_accessible]
      record.errors[:base] << _("Unable to disable safemode_render when bmc_credentials_accessible is disabled")
    end
  end

  def self.default_global_templates
    map_pxe_kind do |pxe_kind, templates|
      set("global_#{pxe_kind}", N_("Global default %s template. This template gets deployed to all configured TFTP servers. It will not be affected by upgrades.") % pxe_kind, ProvisioningTemplate.global_default_name(pxe_kind), N_("Global default %s template") % pxe_kind, nil, { :collection => templates })
    end
  end

  def self.default_local_boot_templates
    map_pxe_kind do |pxe_kind, templates|
      set("local_boot_#{pxe_kind}", N_("Template that will be selected as %s default for local boot.") % pxe_kind, ProvisioningTemplate.local_boot_name(pxe_kind), N_("Local boot %s template") % pxe_kind, nil, { :collection => templates })
    end
  end

  def self.map_pxe_kind
    TemplateKind::PXE.map do |pxe_kind|
      templates = proc { Hash[ProvisioningTemplate.unscoped.of_kind(pxe_kind).map { |tmpl| [tmpl.name, tmpl.name] }] }
      yield pxe_kind, templates
    end
  end

  def self.default_excluded_facts
    IGNORED_INTERFACES + IGNORED_FACTS
  end
end
