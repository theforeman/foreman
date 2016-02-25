require 'facter'
class Setting::Provisioning < Setting
  def self.load_defaults
    # Check the table exists
    return unless super

    fqdn = Facter.value(:fqdn) || SETTINGS[:fqdn]
    unattended_url = "http://#{fqdn}"

    self.transaction do
      [
        self.set('root_pass', N_("Default encrypted root password on provisioned hosts"), nil, N_('Root password')),
        self.set('unattended_url', N_("URL hosts will retrieve templates from during build (normally http as many installers don't support https)"), unattended_url, N_('Unattended URL')),
        self.set('safemode_render', N_("Enable safe mode config templates rendering (recommended)"), true, N_('Safemode rendering')),
        self.set('manage_puppetca', N_("Foreman will automate certificate signing upon provision of new host"), true, N_('Manage PuppetCA')),
        self.set('ignore_puppet_facts_for_provisioning', N_("Stop updating IP address and MAC values from Puppet facts (affects all interfaces)"), false, N_('Ignore Puppet facts for provisioning')),
        self.set('ignored_interface_identifiers', N_("Ignore interfaces that match these values during facts importing, you can use * wildcard to match names with indexes e.g. macvtap*"), ['lo', 'usb*', 'vnet*', 'macvtap*', '_vdsmdummy_'], N_('Ignore interfaces with matching identifier')),
        self.set('query_local_nameservers', N_("Foreman will query the locally configured resolver instead of the SOA/NS authorities"), false, N_('Query local nameservers')),
        self.set('remote_addr', N_("If Foreman is running behind Passenger or a remote load balancer, the IP should be set here. This is a regular expression, so it can support several load balancers, i.e: (10.0.0.1|127.0.0.1)"), "127.0.0.1", N_('Remote address')),
        self.set('token_duration', N_("Time in minutes installation tokens should be valid for, 0 to disable token generation"), 60 * 6, N_('Token duration')),
        self.set('libvirt_default_console_address', N_("The IP address that should be used for the console listen address when provisioning new virtual machines via Libvirt"), "0.0.0.0", N_('Libvirt default console address')),
        self.set('update_ip_from_built_request', N_("Foreman will update the host IP with the IP that made the built request"), false, N_('Update IP from built request')),
        self.set('use_shortname_for_vms', N_("Foreman will use the short hostname instead of the FQDN for creating new virtual machines"), false, N_('Use short name for VMs')),
        self.set('dns_conflict_timeout', N_("Timeout for DNS conflict validation (in seconds)"), 3, N_('DNS conflict timeout')),
        self.set('clean_up_failed_deployment', N_("Foreman will delete virtual machine if provisioning script ends with non zero exit code"), true, N_('Clean up failed deployment')),
        self.set('name_generator_type', N_("Random gives unique names, MAC-based are longer but stable (and only works with bare-metal)"), 'Random-based', N_("Type of name generator"), nil, {:collection => Proc.new {NameGenerator::GENERATOR_TYPES} })
      ].each { |s| self.create! s.update(:category => "Setting::Provisioning")}
    end

    true
  end
end
