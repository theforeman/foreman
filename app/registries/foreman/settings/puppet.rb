Foreman::SettingManager.define(:foreman) do
  category(:puppet, N_('Puppet')) do
    all_environments = proc do
      env_klass = 'ForemanPuppet::Environment'.safe_constantize
      env_klass ? Hash[env_klass.all.map { |env| [env[:name], env[:name]] }] : {}
    end
    setting('puppet_interval',
      type: :integer,
      description: N_("Duration in minutes after servers reporting via Puppet are classed as out of sync."),
      default: 35,
      full_name: N_('Puppet interval'))
    setting('puppet_out_of_sync_disabled',
      type: :boolean,
      description: N_("Disable host configuration status turning to out of sync for %s after report does not arrive within configured interval") % 'Puppet',
      default: false,
      full_name: N_('%s out of sync disabled') % 'Puppet')
    setting('default_puppet_environment',
      type: :string,
      description: N_("Foreman will default to this puppet environment if it cannot auto detect one"),
      default: "production",
      full_name: N_('Default Puppet environment'),
      collection: all_environments)
    setting('Default_parameters_Lookup_Path',
      type: :array,
      description: N_("Foreman will evaluate host smart class parameters in this order by default"),
      default: ["fqdn", "hostgroup", "os", "domain"],
      full_name: N_('Default parameters lookup path'))
    setting('interpolate_erb_in_parameters',
      type: :boolean,
      description: N_("Foreman will parse ERB in parameters value in the ENC output"),
      default: true,
      full_name: N_('Interpolate ERB in parameters'))
    setting('enc_environment',
      type: :boolean,
      description: N_("Foreman will explicitly set the puppet environment in the ENC yaml output. This will avoid conflicts between the environment in puppet.conf and the environment set in Foreman"),
      default: true,
      full_name: N_('ENC environment'))
    setting('use_uuid_for_certificates',
      type: :boolean,
      description: N_("Foreman will use random UUIDs for certificate signing instead of hostnames"),
      default: false,
      full_name: N_('Use UUID for certificates'))
    setting('update_environment_from_facts',
      type: :boolean,
      description: N_("Foreman will update a host's environment from its facts"),
      default: false,
      full_name: N_('Update environment from facts'))
    setting('update_subnets_from_facts',
      type: :string,
      description: N_("Foreman will update a host's subnet from its facts"),
      default: 'none',
      full_name: N_('Update subnets from facts'),
      collection: proc { { 'all' => _('All'), 'provisioning' => _('Provisioning only'), 'none' => _('None') } })
    setting('update_hostgroup_from_facts',
      type: :boolean,
      description: N_("Foreman will update a host's hostgroup from its facts"),
      default: true,
      full_name: N_('Update hostgroup from facts'))
    setting('matchers_inheritance',
      type: :boolean,
      description: N_("Foreman matchers will be inherited by children when evaluating smart class parameters for hostgroups, organizations and locations"),
      default: true,
      full_name: N_('Matchers inheritance'))
    setting('create_new_host_when_facts_are_uploaded',
      type: :boolean,
      description: N_("Foreman will create the host when new facts are received"),
      default: true,
      full_name: N_('Create new host when facts are uploaded'))
    setting('create_new_host_when_report_is_uploaded',
      type: :boolean,
      description: N_("Foreman will create the host when a report is received"),
      default: true,
      full_name: N_('Create new host when report is uploaded'))
    setting('location_fact',
      type: :string,
      description: N_("Hosts created after a puppet run will be placed in the location this fact dictates. The content of this fact should be the full label of the location."),
      default: 'foreman_location',
      full_name: N_('Location fact'))
    setting('organization_fact',
      type: :string,
      description: N_("Hosts created after a puppet run will be placed in the organization this fact dictates. The content of this fact should be the full label of the organization."),
      default: 'foreman_organization',
      full_name: N_('Organization fact'))
    setting('default_location',
      type: :string,
      description: N_("Hosts created after a puppet run that did not send a location fact will be placed in this location"),
      default: '',
      full_name: N_('Default location'),
      collection: proc { Hash[Location.all.pluck(:title).map { |title| [title, title] }] })
    setting('default_organization',
      type: :string,
      description: N_("Hosts created after a puppet run that did not send a organization fact will be placed in this organization"),
      default: '',
      full_name: N_('Default organization'),
      collection: proc { Hash[Organization.all.pluck(:title).map { |title| [title, title] }] })
    setting('always_show_configuration_status',
      type: :boolean,
      description: N_("All hosts will show a configuration status even when a Puppet smart proxy is not assigned"),
      default: false,
      full_name: N_('Always show configuration status'))
  end
end
