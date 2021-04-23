class Setting::Cfgmgmt < Setting
  def self.tool_specific
    @tool_specific ||= {}
  end

  def self.add_tool_specific(tool_name, settings)
    tool_specific[tool_name.to_sym] ||= []
    tool_specific[tool_name.to_sym].concat(settings)
  end

  add_tool_specific 'puppet', [
    set('puppet_interval', N_("Duration in minutes after servers reporting via Puppet are classed as out of sync."), 35, N_('Puppet interval')),
    set('puppet_out_of_sync_disabled', N_("Disable host configuration status turning to out of sync for %s after report does not arrive within configured interval") % 'Puppet', false, N_('%s out of sync disabled') % 'Puppet'),
  ]

  def self.default_settings
    [
      set('matchers_inheritance', N_("Foreman matchers will be inherited by children when evaluating Lookups for Hostgroups, Organizations and Locations"), true, N_('Matchers inheritance')),
      set('Default_parameters_Lookup_Path', N_("Foreman will evaluate host lookups in this order by default"), ["fqdn", "hostgroup", "os", "domain"], N_('Default parameters lookup path')),
      set('interpolate_erb_in_parameters', N_("Foreman will parse ERB in parameters and lookup values"), true, N_('Interpolate ERB in parameters')),
      set('create_new_host_when_report_is_uploaded', N_("Foreman will create the host when a configuration report is received"), true, N_('Create new host when report is uploaded')),
      set('always_show_configuration_status', N_("All hosts will show a configuration status even when there is no configuration report for the Host"), false, N_('Always show configuration status')),
    ] + tool_specific.values.flatten
  end

  def self.humanized_category
    N_('Configuration management')
  end
end
