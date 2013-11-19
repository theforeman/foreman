class Setting::Puppet < Setting

  def self.load_defaults
    # Check the table exists
    return unless super

    self.transaction do
      [
        self.set('puppet_interval', N_("Puppet interval in minutes"), 30 ),
        self.set('default_puppet_environment', N_("The Puppet environment Foreman will default to in case it can't auto detect it"), "production"),
        self.set('modulepath',N_("The Puppet default module path in case Foreman can't auto detect it"), "/etc/puppet/modules"),
        self.set('document_root', N_("Document root where puppetdoc files should be created"), "#{Rails.root}/public/puppet/rdoc"),
        self.set('puppetrun', N_("Enables Puppetrun support"), false),
        self.set('puppet_server', N_("Default Puppet server systemname"), "puppet"),
        self.set('failed_report_email_notification', N_("Enable Email alerts per each failed Puppet report"), false),
        self.set('Default_variables_Lookup_Path', N_("The Default path in which Foreman resolves system specific variables"), ["fqdn", "system_group", "os", "domain"]),
        self.set('Enable_Smart_Variables_in_ENC', N_("Should the smart variables be exposed via the ENC yaml output?"), true),
        self.set('Parametrized_Classes_in_ENC', N_("Should Foreman use the new format (2.6.5+) to answer Puppet in its ENC yaml output?"), true),
        self.set('interpolate_erb_in_parameters', N_("Should Foreman parse ERB to return dynamic parameters?"), true),
        self.set('enc_environment', N_("Should Foreman provide puppet environment in ENC yaml output? (this avoids the mismatch error between puppet.conf and ENC environment)"), true),
        self.set('use_uuid_for_certificates', N_("Should Foreman use random UUID's for certificate signing instead of systemnames"), false),
        self.set('update_environment_from_facts', N_("Should Foreman update a system's environment from its facts"), false),
        self.set('remove_classes_not_in_environment', N_("When system and system group have different environments should all classes be included (regardless if they exists or not in the other environment)"), false),
        self.set('system_group_matchers_inheritance', N_("Should Foreman use system group ancestors matchers to set puppet classes parameters values"), true),
        self.set('create_new_system_when_facts_are_uploaded', N_("Foreman will create the system when new facts are received"), true),
        self.set('create_new_system_when_report_is_uploaded', N_("Foreman will create the system when a report is received"), true),
        self.set('legacy_puppet_systemname', N_("Foreman will truncate systemname to 'puppet' if it starts with puppet"), false)
      ].compact.each { |s| self.create s.update(:category => "Setting::Puppet")}

      true

    end

  end

end
