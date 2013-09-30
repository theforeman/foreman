require 'facter'
class Setting::Provisioning < Setting

  def self.load_defaults
    # Check the table exists
    return unless super

    ssl_cert     = "#{SETTINGS[:puppetvardir]}/ssl/certs/#{Facter.fqdn}.pem"
    ssl_ca_file  = "#{SETTINGS[:puppetvardir]}/ssl/certs/ca.pem"
    ssl_priv_key = "#{SETTINGS[:puppetvardir]}/ssl/private_keys/#{Facter.fqdn}.pem"

    self.transaction do
      [
        self.set('root_pass', N_("Default encrypted root password on provisioned hosts (default is 123123)"), "xybxa6JUkz63w"),
        self.set('safemode_render', N_("Enable safe mode config templates rendering (recommended)"), true),
        self.set('ssl_certificate', N_("SSL Certificate path that Foreman would use to communicate with its proxies"), ssl_cert),
        self.set('ssl_ca_file', N_( "SSL CA file that Foreman will use to communicate with its proxies"), ssl_ca_file),
        self.set('ssl_priv_key', N_("SSL Private Key file that Foreman will use to communicate with its proxies"), ssl_priv_key),
        self.set('manage_puppetca', N_("Should Foreman automate certificate signing upon provisioning new host"), true),
        self.set('ignore_puppet_facts_for_provisioning', N_("Does not update ipaddress and MAC values from Puppet facts"), false),
        self.set('query_local_nameservers', N_("Should Foreman query the locally configured name server or the SOA/NS authorities"), false),
        self.set('remote_addr', N_("If Foreman is running behind Passenger or a remote load balancer, the IP should be set here. This is a regular expression, so it can support several load balancers, i.e: (10.0.0.1|127.0.0.1)"), "127.0.0.1"),
        self.set('token_duration', N_("Time in minutes installation tokens should be valid for, 0 to disable"), 0),
        self.set('libvirt_default_console_address', N_("The IP address that should be used for the console listen address when provisioning new virtual machines via Libvirt"), "0.0.0.0"),
        self.set('update_ip_from_built_request', N_("Should we use the originating IP of the built request to update the host's IP?"), false),
        self.set('use_shortname_for_vms', N_("Should Foreman use the short hostname instead of the FQDN for creating new virtual machines"), false)
      ].each { |s| self.create! s.update(:category => "Setting::Provisioning")}
    end

    true

  end

end
