class Setting::Puppet < Setting
  after_save :reload_topbar, :if => ->(setting) { setting.name == 'puppet_enabled' }

  def self.load_defaults
    # Check the table exists
    return unless super

    self.transaction do
      [
        self.set('puppet_enabled', N_("Whether Puppet-related settings are visible in Foreman"), true, N_('Enable Puppet')),
        self.set('puppet_interval', N_("Puppet interval in minutes"), 30, N_('Puppet interval')),
        self.set('outofsync_interval', N_("Duration in minutes after the Puppet interval for servers to be classed as out of sync."), 5, N_('Out of sync interval')),
        self.set('default_puppet_environment', N_("Foreman will default to this puppet environment if it cannot auto detect one"), "production", N_('Default Puppet environment'), nil, { :collection => Proc.new {Hash[Environment.all.map{|env| [env[:name], env[:name]]}]} }),
        self.set('modulepath',N_("Foreman will set this as the default Puppet module path if it cannot auto detect one"), "/etc/puppet/modules", N_('Module path')),
        self.set('document_root', N_("Document root where puppetdoc files should be created"), "#{Rails.root}/public/puppet/rdoc", N_('Document root')),
        self.set('puppetrun', N_("Enable puppetrun support"), false, N_('Puppetrun')),
        self.set('puppet_server', N_("Default Puppet server hostname"), "puppet", N_('Puppet server')),
        self.set('Default_variables_Lookup_Path', N_("Foreman will evaluate host smart variables in this order by default"), ["fqdn", "hostgroup", "os", "domain"], N_('Default variables lookup path')),
        self.set('Enable_Smart_Variables_in_ENC', N_("Foreman smart variables will be exposed via the ENC yaml output"), true, N_('Enable smart variables in ENC')),
        self.set('Parametrized_Classes_in_ENC', N_("Foreman will use the new (2.6.5+) format for classes in the ENC yaml output"), true, N_('Parameterized classes in ENC')),
        self.set('interpolate_erb_in_parameters', N_("Foreman will parse ERB in parameters value in the ENC output"), true, N_('Interpolate ERB in parameters')),
        self.set('enc_environment', N_("Foreman will explicitly set the puppet environment in the ENC yaml output. This will avoid conflicts between the environment in puppet.conf and the environment set in Foreman"), true, N_('ENC environment')),
        self.set('use_uuid_for_certificates', N_("Foreman will use random UUIDs for certificate signing instead of hostnames"), false, N_('Use UUID for certificates')),
        self.set('update_environment_from_facts', N_("Foreman will update a host's environment from its facts"), false, N_('Update environment from facts')),
        self.set('host_group_matchers_inheritance', N_("Foreman host group matchers will be inherited by children when evaluating smart class parameters"), true, N_('Host group matchers inheritance')),
        self.set('create_new_host_when_facts_are_uploaded', N_("Foreman will create the host when new facts are received"), true, N_('Create new host when facts are uploaded')),
        self.set('create_new_host_when_report_is_uploaded', N_("Foreman will create the host when a report is received"), true, N_('Create new host when report is uploaded')),
        self.set('legacy_puppet_hostname', N_("Foreman will truncate hostname to 'puppet' if it starts with puppet"), false, N_('Legacy Puppet hostname')),
        self.set('location_fact', N_("Hosts created after a puppet run will be placed in the location this fact dictates. The content of this fact should be the full label of the location."), 'foreman_location', N_('Location fact')),
        self.set('organization_fact', N_("Hosts created after a puppet run will be placed in the organization this fact dictates. The content of this fact should be the full label of the organization."), 'foreman_organization', N_('Organization fact')),
        self.set('default_location', N_("Hosts created after a puppet run that did not send a location fact will be placed in this location"), '', N_('Default location'), nil, { :collection => Proc.new {Hash[Location.all.map{|loc| [loc[:title], loc[:title]]}]} }),
        self.set('default_organization', N_("Hosts created after a puppet run that did not send a organization fact will be placed in this organization"), '', N_('Default organization'), nil, {:collection => Proc.new {Hash[Organization.all.map{|org| [org[:title], org[:title]]}]} }),
        self.set('always_show_configuration_status', N_("All hosts will show a configuration status even when a Puppet smart proxy is not assigned"), false, N_('Always show configuration status'))
      ].compact.each { |s| self.create s.update(:category => "Setting::Puppet")}

      true
    end
  end

  private

  def reload_topbar
    # Force configure menu reload
    if Setting[:puppet_enabled]
      top_menu.divider(:caption => N_('Puppet'), :parent => :configure_menu)
      top_menu.item(:environments,
                    :caption  => N_('Environments'),
                    :parent   => :configure_menu)
      top_menu.item(:puppetclasses,
                    :caption  => N_('Classes'),
                    :parent   => :configure_menu)
      top_menu.item(:config_groups,
                    :caption  => N_('Config groups'),
                    :parent   => :configure_menu)
      top_menu.item(:variable_lookup_keys,
                    :caption  => N_('Smart variables'),
                    :parent   => :configure_menu)
      top_menu.item(:puppetclass_lookup_keys,
                    :caption  => N_('Smart class parameters'),
                    :parent   => :configure_menu)
    else
      top_menu.delete(:environments)
      top_menu.delete(:puppetclasses)
      top_menu.delete(:config_groups)
      top_menu.delete(:variable_lookup_keys)
      top_menu.delete(:puppetclass_lookup_keys)
    end
  end

  def top_menu
    Menu::Manager.map(:top_menu)
  end
end
