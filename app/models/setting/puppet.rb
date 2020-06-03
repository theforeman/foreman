class Setting::Puppet < Setting
  def self.update_subnets_from_facts_types
    {
      'all' => _('All'),
      'provisioning' => _('Provisioning only'),
      'none' => _('None'),
    }
  end

  def self.default_settings
    [
      set('puppet_interval', N_("Duration in minutes after servers reporting via Puppet are classed as out of sync."), 35, N_('Puppet interval')),
      set('puppet_out_of_sync_disabled', N_("Disable host configuration status turning to out of sync for %s after report does not arrive within configured interval") % 'Puppet', false, N_('%s out of sync disabled') % 'Puppet'),
      set('default_puppet_environment', N_("Foreman will default to this puppet environment if it cannot auto detect one"), "production", N_('Default Puppet environment'), nil, { :collection => proc { Hash[Environment.all.map { |env| [env[:name], env[:name]] }] } }),
      set('Default_parameters_Lookup_Path', N_("Foreman will evaluate host smart class parameters in this order by default"), ["fqdn", "hostgroup", "os", "domain"], N_('Default parameters lookup path')),
      set('interpolate_erb_in_parameters', N_("Foreman will parse ERB in parameters value in the ENC output"), true, N_('Interpolate ERB in parameters')),
      set('enc_environment', N_("Foreman will explicitly set the puppet environment in the ENC yaml output. This will avoid conflicts between the environment in puppet.conf and the environment set in Foreman"), true, N_('ENC environment')),
      set('use_uuid_for_certificates', N_("Foreman will use random UUIDs for certificate signing instead of hostnames"), false, N_('Use UUID for certificates')),
      set('update_environment_from_facts', N_("Foreman will update a host's environment from its facts"), false, N_('Update environment from facts')),
      set('update_subnets_from_facts', N_("Foreman will update a host's subnet from its facts"), 'none', N_('Update subnets from facts'), nil, { :collection => proc { update_subnets_from_facts_types } }),
      set('update_hostgroup_from_facts', N_("Foreman will update a host's hostgroup from its facts"), true, N_('Update hostgroup from facts')),
      set('matchers_inheritance', N_("Foreman matchers will be inherited by children when evaluating smart class parameters for hostgroups, organizations and locations"), true, N_('Matchers inheritance')),
      set('create_new_host_when_facts_are_uploaded', N_("Foreman will create the host when new facts are received"), true, N_('Create new host when facts are uploaded')),
      set('create_new_host_when_report_is_uploaded', N_("Foreman will create the host when a report is received"), true, N_('Create new host when report is uploaded')),
      set('location_fact', N_("Hosts created after a puppet run will be placed in the location this fact dictates. The content of this fact should be the full label of the location."), 'foreman_location', N_('Location fact')),
      set('organization_fact', N_("Hosts created after a puppet run will be placed in the organization this fact dictates. The content of this fact should be the full label of the organization."), 'foreman_organization', N_('Organization fact')),
      set('default_location', N_("Hosts created after a puppet run that did not send a location fact will be placed in this location"), '', N_('Default location'), nil, { :collection => proc { Hash[Location.all.map { |loc| [loc[:title], loc[:title]] }] } }),
      set('default_organization', N_("Hosts created after a puppet run that did not send a organization fact will be placed in this organization"), '', N_('Default organization'), nil, {:collection => proc { Hash[Organization.all.map { |org| [org[:title], org[:title]] }] } }),
      set('always_show_configuration_status', N_("All hosts will show a configuration status even when a Puppet smart proxy is not assigned"), false, N_('Always show configuration status')),
    ]
  end

  def self.humanized_category
    N_('Puppet')
  end
end
