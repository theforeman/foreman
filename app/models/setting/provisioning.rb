require 'puppet_setting'
class Setting::Provisioning < Setting

  def self.load_defaults
    # Check the table exists
    return unless super

    ppsettings = PuppetSetting.new.get :hostcert, :localcacert, :hostprivkey, :storeconfigs
    self.transaction do
      Setting::Provisioning.init_on_startup!('root_pass', N_("Default encrypted root password on provisioned hosts (default is 123123)"), "xybxa6JUkz63w")
      Setting::Provisioning.init_on_startup!('safemode_render', N_("Enable safe mode config templates rendering (recommended)"), true)
      Setting::Provisioning.init_on_startup!('ssl_certificate', N_("SSL Certificate path that Foreman would use to communicate with its proxies"), ppsettings[:hostcert])
      Setting::Provisioning.init_on_startup!('ssl_ca_file', N_( "SSL CA file that Foreman will use to communicate with its proxies"), ppsettings[:localcacert])
      Setting::Provisioning.init_on_startup!('ssl_priv_key', N_("SSL Private Key file that Foreman will use to communicate with its proxies"), ppsettings[:hostprivkey])
      Setting::Provisioning.init_on_startup!('manage_puppetca', N_("Should Foreman automate certificate signing upon provisioning new host"), true)
      Setting::Provisioning.init_on_startup!('ignore_puppet_facts_for_provisioning', N_("Does not update ipaddress and MAC values from Puppet facts"), false)
      Setting::Provisioning.init_on_startup!('query_local_nameservers', N_("Should Foreman query the locally configured name server or the SOA/NS authorities"), false)
      Setting::Provisioning.init_on_startup!('remote_addr', N_("If Foreman is running behind Passenger or a remote load balancer, the IP should be set here. This is a regular expression, so it can support several load balancers, i.e: (10.0.0.1|127.0.0.1)"), "127.0.0.1")
      Setting::Provisioning.init_on_startup!('token_duration', N_("Time in minutes installation tokens should be valid for, 0 to disable"), 0)
      Setting::Provisioning.init_on_startup!('libvirt_default_console_address', N_("The IP address that should be used for the console listen address when provisioning new virtual machines via Libvirt"), "0.0.0.0")
      Setting::Provisioning.init_on_startup!('update_ip_from_built_request', N_("Should we use the originating IP of the built request to update the host's IP?"), false)
    end
    true
  end
end
