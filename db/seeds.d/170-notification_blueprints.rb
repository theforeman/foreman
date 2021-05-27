blueprints = [
  {
    group: N_('Hosts'),
    name: 'host_build_completed',
    message: N_('%{subject} has been provisioned successfully'),
    level: 'success',
    actions:
    {
      links:
      [
        path_method: :host_path,
        title: N_('Details'),
      ],
    },
  },
  {
    group: N_('Hosts'),
    name: 'host_destroyed',
    message: N_('%{subject} has been deleted successfully'),
    level: 'info',
  },
  {
    group: N_('Hosts'),
    name: 'host_missing_owner',
    message: N_('%{subject} has no owner set'),
    level: 'warning',
    actions:
    {
      links:
      [
        path_method: :edit_host_path,
        title: N_('Update host'),
      ],
    },
  },
  {
    group: N_('Community'),
    name: 'rss_post',
    level: 'info',
    message: N_('RSS post message goes here'),
    actions:
    {
      links:
      [
        title: N_('URL'),
        external: true,
      ],
    },
  },
  {
    group: N_('Deprecations'),
    name: 'setting_deprecation',
    level: 'warning',
    message: N_('The %{setting} setting has been deprecated and will be removed in version %{version}'),
    expires_in: 30.days,
  },
  {
    group: N_('Deprecations'),
    name: 'feature_deprecation',
    level: 'warning',
    message: N_('Support for %{feature} has been deprecated and will be removed in version %{version}'),
    expires_in: 30.days,
  },
  {
    group: N_('Reports'),
    name: 'report_finish',
    message: N_('Report is ready to download'),
    level: 'info',
    actions:
    {
      links:
      [
        {
          path_method: :edit_host_path,
          title: N_('Download Report'),
        },
        {
          path_method: :edit_host_path,
          title: N_('Regenerate Report'),
        },
      ],
    },
  },
]

blueprints.each { |blueprint| UINotifications::Seed.new(blueprint).configure }
