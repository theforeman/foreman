require 'facter'
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
  validates :value, :pxe_template_name => true, :if => Proc.new { |s| s.class.default_global_labels.include?(s.name) }

  def self.default_settings
    fqdn = Facter.value(:fqdn) || SETTINGS[:fqdn]
    unattended_url = "http://#{fqdn}"
    select = [{:name => _("Users"), :class => 'user', :scope => 'visible', :value_method => 'id_and_type', :text_method => 'login'},
              {:name => _("Usergroup"), :class => 'usergroup', :scope => 'visible', :value_method => 'id_and_type', :text_method => 'name'}]

    [
      self.set('host_owner', N_("Default owner on provisioned hosts, if empty Foreman will use current user"), nil, N_('Host owner'), nil, {:collection => Proc.new { select }, :include_blank => _("Select an owner")}),
      self.set('root_pass', N_("Default encrypted root password on provisioned hosts"), nil, N_('Root password')),
      self.set('unattended_url', N_("URL hosts will retrieve templates from during build (normally http as many installers don't support https)"), unattended_url, N_('Unattended URL')),
      self.set('safemode_render', N_("Enable safe mode config templates rendering (recommended)"), true, N_('Safemode rendering')),
      self.set('access_unattended_without_build', N_("Allow access to unattended URLs without build mode being used"), false, N_('Access unattended without build')),
      self.set('manage_puppetca', N_("Foreman will automate certificate signing upon provision of new host"), true, N_('Manage PuppetCA')),
      self.set('ignore_puppet_facts_for_provisioning', N_("Stop updating IP address and MAC values from Puppet facts (affects all interfaces)"), false, N_('Ignore Puppet facts for provisioning')),
      self.set('ignored_interface_identifiers', N_("Ignore interfaces that match these values during facts importing, you can use * wildcard to match names with indexes e.g. macvtap*"), ['lo', 'usb\d+', 'vnet\d+', 'macvtap\d+', '_vdsmdummy_', 'veth\d+', 'docker\d+'], N_('Ignore interfaces with matching identifier')),
      self.set('ignore_facts_for_operatingsystem', N_("Stop updating Operating System from facts"), false, N_('Ignore facts for operating system')),
      self.set('ignore_facts_for_domain', N_("Stop updating domain values from facts"), false, N_('Ignore facts for domain')),
      self.set('query_local_nameservers', N_("Foreman will query the locally configured resolver instead of the SOA/NS authorities"), false, N_('Query local nameservers')),
      self.set('remote_addr', N_("If Foreman is running behind Passenger or a remote load balancer, the IP should be set here. This is a regular expression, so it can support several load balancers, i.e: (10.0.0.1|127.0.0.1)"), "127.0.0.1", N_('Remote address')),
      self.set('token_duration', N_("Time in minutes installation tokens should be valid for, 0 to disable token generation"), 60 * 6, N_('Token duration')),
      self.set('libvirt_default_console_address', N_("The IP address that should be used for the console listen address when provisioning new virtual machines via Libvirt"), "0.0.0.0", N_('Libvirt default console address')),
      self.set('update_ip_from_built_request', N_("Foreman will update the host IP with the IP that made the built request"), false, N_('Update IP from built request')),
      self.set('use_shortname_for_vms', N_("Foreman will use the short hostname instead of the FQDN for creating new virtual machines"), false, N_('Use short name for VMs')),
      self.set('dns_conflict_timeout', N_("Timeout for DNS conflict validation (in seconds)"), 3, N_('DNS conflict timeout')),
      self.set('clean_up_failed_deployment', N_("Foreman will delete virtual machine if provisioning script ends with non zero exit code"), true, N_('Clean up failed deployment')),
      self.set('name_generator_type', N_("Random gives unique names, MAC-based are longer but stable (and only works with bare-metal)"), 'Random-based', N_("Type of name generator"), nil, {:collection => Proc.new {NameGenerator::GENERATOR_TYPES} })
    ] + default_global_templates + default_local_boot_templates
  end

  def self.load_defaults
    # Check the table exists
    return unless super

    self.transaction do
      default_settings.each { |s| self.create! s.update(:category => "Setting::Provisioning")}
    end

    true
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
      self.set("global_#{pxe_kind}", N_("Global default %s template. This template gets deployed to all configured TFTP servers. It will not be affected by upgrades.") % pxe_kind, ProvisioningTemplate.global_default_name(pxe_kind), N_("Global default %s template") % pxe_kind, nil, { :collection =>  templates })
    end
  end

  def self.default_local_boot_templates
    map_pxe_kind do |pxe_kind, templates|
      self.set("local_boot_#{pxe_kind}", N_("Template that will be selected as %s default for local boot.") % pxe_kind, ProvisioningTemplate.local_boot_name(pxe_kind), N_("Local boot %s template") % pxe_kind, nil, { :collection => templates })
    end
  end

  def self.map_pxe_kind
    TemplateKind::PXE.map do |pxe_kind|
      templates = Proc.new { Hash[ProvisioningTemplate.unscoped.of_kind(pxe_kind).map { |tmpl| [tmpl.name, tmpl.name] }] }
      yield pxe_kind, templates
    end
  end
end
