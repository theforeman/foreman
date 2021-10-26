Foreman::SettingManager.define(:foreman) do
  category(:cfgmgmt, N_('Config Management')) do
    setting('create_new_host_when_report_is_uploaded',
      type: :boolean,
      description: N_("Foreman will create the host when a report is received"),
      default: true,
      full_name: N_('Create new host when report is uploaded'))
    setting('matchers_inheritance',
      type: :boolean,
      description: N_("Foreman matchers will be inherited by children when evaluating smart class parameters for hostgroups, organizations and locations"),
      default: true,
      full_name: N_('Matchers inheritance'))
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
    setting('always_show_configuration_status',
      type: :boolean,
      description: N_("All hosts will show a configuration status even when a Puppet smart proxy is not assigned"),
      default: false,
      full_name: N_('Always show configuration status'))
  end
end

Foreman::SettingManager.define(:puppet) do
  category(:cfgmgmt, N_('Config Management')) do
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
  end
end
