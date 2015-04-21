require 'facter'
class Setting::Provisioning < Setting
  def self.load_defaults
    # Check the table exists
    return unless super

    fqdn = Facter.value(:fqdn) || SETTINGS[:fqdn]
    unattended_url = "http://#{fqdn}"

    self.transaction do
      [
        self.set('root_pass', N_("Default encrypted root password on provisioned hosts"), nil),
        self.set('unattended_url', N_("URL hosts will retrieve templates from during build (normally http as many installers don't support https)"), unattended_url),
        self.set('safemode_render', N_("Enable safe mode config templates rendering (recommended)"), true),
        self.set('manage_puppetca', N_("Foreman will automate certificate signing upon provision of new host"), true),
        self.set('ignore_puppet_facts_for_provisioning', N_("Stop updating IP address and MAC values from Puppet facts (affects all interfaces)"), false),
        self.set('query_local_nameservers', N_("Foreman will query the locally configured resolver instead of the SOA/NS authorities"), false),
        self.set('remote_addr', N_("If Foreman is running behind Passenger or a remote load balancer, the IP should be set here. This is a regular expression, so it can support several load balancers, i.e: (10.0.0.1|127.0.0.1)"), "127.0.0.1"),
        self.set('token_duration', N_("Time in minutes installation tokens should be valid for, 0 to disable token generation"), 60 * 6),
        self.set('libvirt_default_console_address', N_("The IP address that should be used for the console listen address when provisioning new virtual machines via Libvirt"), "0.0.0.0"),
        self.set('update_ip_from_built_request', N_("Foreman will update the host IP with the IP that made the built request"), false),
        self.set('use_shortname_for_vms', N_("Foreman will use the short hostname instead of the FQDN for creating new virtual machines"), false),
      ].each { |s| self.create! s.update(:category => "Setting::Provisioning")}
    end

    true
  end
end
