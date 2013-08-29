require 'rubygems'
require 'puppet_setting'
class Setting::Puppet < Setting

  def self.load_defaults
    # Check the table exists
    return unless super

    param_enc = Gem::Version.new(Facter.puppetversion.split('-').first) >= Gem::Version.new('2.6.5')
    ppsettings = PuppetSetting.new.get :storeconfigs
    self.transaction do
      Setting::Puppet.init_on_startup!('puppet_interval', N_("Puppet interval in minutes"), 30 )
      Setting::Puppet.init_on_startup!('default_puppet_environment', N_("The Puppet environment Foreman will default to in case it can't auto detect it"), "production")
      Setting::Puppet.init_on_startup!('modulepath',N_("The Puppet default module path in case Foreman can't auto detect it"), "/etc/puppet/modules")
      Setting::Puppet.init_on_startup!('document_root', N_("Document root where puppetdoc files should be created"), "#{Rails.root}/public/puppet/rdoc")
      Setting::Puppet.init_on_startup!('puppetrun', N_("Enables Puppetrun support"), false)
      Setting::Puppet.init_on_startup!('puppet_server', N_("Default Puppet server hostname"), "puppet")
      Setting::Puppet.init_on_startup!('failed_report_email_notification', N_("Enable Email alerts per each failed Puppet report"), false)
      Setting::Puppet.init_on_startup!('using_storeconfigs', N_("Foreman is sharing its database with Puppet Store configs"), ppsettings[:storeconfigs] == 'true')
      Setting::Puppet.init_on_startup!('Default_variables_Lookup_Path', N_("The Default path in which Foreman resolves host specific variables"), ["fqdn", "hostgroup", "os", "domain"])
      Setting::Puppet.init_on_startup!('Enable_Smart_Variables_in_ENC', N_("Should the smart variables be exposed via the ENC yaml output?"), true)
      Setting::Puppet.init_on_startup!('Parametrized_Classes_in_ENC', N_("Should Foreman use the new format (2.6.5+) to answer Puppet in its ENC yaml output?"), param_enc)
      Setting::Puppet.init_on_startup!('enc_environment', N_("Should Foreman provide puppet environment in ENC yaml output? (this avoids the mismatch error between puppet.conf and ENC environment)"), true)
      Setting::Puppet.init_on_startup!('use_uuid_for_certificates', N_("Should Foreman use random UUID's for certificate signing instead of hostnames"), false)
      Setting::Puppet.init_on_startup!('update_environment_from_facts', N_("Should Foreman update a host's environment from its facts"), false)
      Setting::Puppet.init_on_startup!('remove_classes_not_in_environment', N_("When host and host group have different environments should all classes be included (regardless if they exists or not in the other environment)"), false)
      Setting::Puppet.init_on_startup!('host_group_matchers_inheritance', N_("Should Foreman use host group ancestors matchers to set puppet classes parameters values"), true)
      Setting::Puppet.init_on_startup!('create_new_host_when_facts_are_uploaded', N_("Foreman will create the host when new facts are received"), true)
      true
    end
  end
end
