require 'puppet_setting'
class Setting::Provisioning < Setting

  def self.load_defaults
    # Check the table exists
    return unless super

    ppsettings = PuppetSetting.new.get :hostcert, :localcacert, :hostprivkey, :storeconfigs
    self.transaction do
      [
        self.set('root_pass', N_("Default encrypted root password on provisioned hosts (default is 123123)"), "xybxa6JUkz63w"),
        self.set('safemode_render', N_("Enable safe mode config templates rendering (recommended)"), true),
        self.set('ssl_certificate', N_("SSL Certificate path that Foreman would use to communicate with its proxies"), ppsettings[:hostcert]),
        self.set('ssl_ca_file', N_( "SSL CA file that Foreman will use to communicate with its proxies"), ppsettings[:localcacert]),
        self.set('ssl_priv_key', N_("SSL Private Key file that Foreman will use to communicate with its proxies"), ppsettings[:hostprivkey]),
        self.set('manage_puppetca', N_("Should Foreman automate certificate signing upon provisioning new host"), true),
        self.set('ignore_puppet_facts_for_provisioning', N_("Does not update ipaddress and MAC values from Puppet facts"), false),
        self.set('query_local_nameservers', N_("Should Foreman query the locally configured name server or the SOA/NS authorities"), false),
        self.set('remote_addr', N_("If Foreman is running behind Passenger or a remote loadbalancer, the ip should be set here"), "127.0.0.1"),
        self.set('token_duration', N_("Time in minutes installation tokens should be valid for, 0 to disable"), 0),
        self.set('libvirt_default_console_address', N_("The IP address that should be used for the console listen address when provisioning new virtual machines via Libvirt"), "0.0.0.0")
      ].each { |s| self.create! s.update(:category => "Setting::Provisioning")}
    end

    true

  end

end
