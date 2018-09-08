class Setting::Puppet < Setting
  def self.default_settings
    [
      self.set('puppet_interval', N_("Duration in minutes after servers reporting via Puppet are classed as out of sync."), 35, N_('Puppet interval')),
      self.set('puppet_out_of_sync_disabled', N_("Disable host configuration status turning to out of sync for %s after report does not arrive within configured interval") % 'Puppet', false, N_('%s out of sync disabled') % 'Puppet'),
      self.set('default_puppet_environment', N_("Foreman will default to this puppet environment if it cannot auto detect one"), "production", N_('Default Puppet environment'), nil, { :collection => Proc.new {Hash[Environment.all.map {|env| [env[:name], env[:name]]}]} }),
      self.set('puppetrun', N_("Enable puppetrun support"), false, N_('Puppetrun')),
      self.set('puppet_server', N_("Default Puppet server hostname"), "puppet", N_('Puppet server')),
      self.set('Default_variables_Lookup_Path', N_("Foreman will evaluate host smart variables in this order by default"), ["fqdn", "hostgroup", "os", "domain"], N_('Default variables lookup path')),
      self.set('Enable_Smart_Variables_in_ENC', N_("Foreman smart variables will be exposed via the ENC yaml output"), true, N_('Enable smart variables in ENC')),
      self.set('Parametrized_Classes_in_ENC', N_("Foreman will use the new (2.6.5+) format for classes in the ENC yaml output"), true, N_('Parameterized classes in ENC')),
      self.set('interpolate_erb_in_parameters', N_("Foreman will parse ERB in parameters value in the ENC output"), true, N_('Interpolate ERB in parameters')),
      self.set('enc_environment', N_("Foreman will explicitly set the puppet environment in the ENC yaml output. This will avoid conflicts between the environment in puppet.conf and the environment set in Foreman"), true, N_('ENC environment')),
      self.set('use_uuid_for_certificates', N_("Foreman will use random UUIDs for certificate signing instead of hostnames"), false, N_('Use UUID for certificates')),
      self.set('update_environment_from_facts', N_("Foreman will update a host's environment from its facts"), false, N_('Update environment from facts')),
      self.set('update_subnets_from_facts', N_("Foreman will update a host's subnet from its facts"), false, N_('Update subnets from facts')),
      self.set('host_group_matchers_inheritance', N_("Foreman host group matchers will be inherited by children when evaluating smart class parameters"), true, N_('Host group matchers inheritance')),
      self.set('create_new_host_when_facts_are_uploaded', N_("Foreman will create the host when new facts are received"), true, N_('Create new host when facts are uploaded')),
      self.set('create_new_host_when_report_is_uploaded', N_("Foreman will create the host when a report is received"), true, N_('Create new host when report is uploaded')),
      self.set('location_fact', N_("Hosts created after a puppet run will be placed in the location this fact dictates. The content of this fact should be the full label of the location."), 'foreman_location', N_('Location fact')),
      self.set('organization_fact', N_("Hosts created after a puppet run will be placed in the organization this fact dictates. The content of this fact should be the full label of the organization."), 'foreman_organization', N_('Organization fact')),
      self.set('default_location', N_("Hosts created after a puppet run that did not send a location fact will be placed in this location"), '', N_('Default location'), nil, { :collection => Proc.new {Hash[Location.all.map {|loc| [loc[:title], loc[:title]]}]} }),
      self.set('default_organization', N_("Hosts created after a puppet run that did not send a organization fact will be placed in this organization"), '', N_('Default organization'), nil, {:collection => Proc.new {Hash[Organization.all.map {|org| [org[:title], org[:title]]}]} }),
      self.set('always_show_configuration_status', N_("All hosts will show a configuration status even when a Puppet smart proxy is not assigned"), false, N_('Always show configuration status'))
    ]
  end

  def self.load_defaults
    # Check the table exists
    return unless super

    self.transaction do
      default_settings.compact.each { |s| self.create s.update(:category => "Setting::Puppet")}
    end

    true
  end

  def self.humanized_category
    N_('Puppet')
  end
end
