class Setting::Puppet < Setting

  def self.load_defaults
    # Check the table exists
    return unless super

    self.transaction do
      [
        self.set('puppet_interval', N_("Puppet interval in minutes"), 30 ),
        self.set('default_puppet_environment', N_("Foreman will default to this puppet environment if it cannot auto detect one"), "production"),
        self.set('modulepath',N_("Foreman will set this as the default Puppet module path if it cannot auto detect one"), "/etc/puppet/modules"),
        self.set('document_root', N_("Document root where puppetdoc files should be created"), "#{Rails.root}/public/puppet/rdoc"),
        self.set('puppetrun', N_("Enable puppetrun support"), false),
        self.set('puppet_server', N_("Default Puppet server hostname"), "puppet"),
        self.set('failed_report_email_notification', N_("Enable email alerts per each failed Puppet report"), false),
        self.set('Default_variables_Lookup_Path', N_("Foreman will evaluate host smart variables in this order by default"), ["fqdn", "hostgroup", "os", "domain"]),
        self.set('Enable_Smart_Variables_in_ENC', N_("Foreman smart variables will be exposed via the ENC yaml output"), true),
        self.set('Parametrized_Classes_in_ENC', N_("Foreman will use the new (2.6.5+) format for classes in the ENC yaml output"), true),
        self.set('interpolate_erb_in_parameters', N_("Foreman will parse ERB in parameters value in the ENC output"), true),
        self.set('enc_environment', N_("Foreman will explicitly set the puppet environment in the ENC yaml output. This will avoid conflicts between the environment in puppet.conf and the environment set in Foreman"), true),
        self.set('use_uuid_for_certificates', N_("Foreman will use random UUIDs for certificate signing instead of hostnames"), false),
        self.set('update_environment_from_facts', N_("Foreman will update a host's environment from its facts"), false),
        self.set('host_group_matchers_inheritance', N_("Foreman host group matchers will be inherited by children when evaluating smart class parameters"), true),
        self.set('create_new_host_when_facts_are_uploaded', N_("Foreman will create the host when new facts are received"), true),
        self.set('create_new_host_when_report_is_uploaded', N_("Foreman will create the host when a report is received"), true),
        self.set('legacy_puppet_hostname', N_("Foreman will truncate hostname to 'puppet' if it starts with puppet"), false),
        self.set('location_fact', N_("Hosts created after a puppet run will be placed in the location this fact dictates. The content of this fact should be the full label of the location."), 'foreman_location'),
        self.set('organization_fact', N_("Hosts created after a puppet run will be placed in the organization this fact dictates. The content of this fact should be the full label of the organization."), 'foreman_organization'),
        self.set('default_location', N_("Hosts created after a puppet run that did not send a location fact will be placed in this location"), ''),
        self.set('default_organization', N_("Hosts created after a puppet run that did not send a organization fact will be placed in this organization"), '')
      ].compact.each { |s| self.create s.update(:category => "Setting::Puppet")}

      true

    end

  end

end
