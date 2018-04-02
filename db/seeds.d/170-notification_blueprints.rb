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
        title: N_('Details')
      ]
    }
  },
  {
    group: N_('Hosts'),
    name: 'host_destroyed',
    message: N_('%{subject} has been deleted successfully'),
    level: 'info'
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
        title: N_('Update host')
      ]
    }
  },
  {
    group: _('Community'),
    name: 'rss_post',
    level: 'info',
    message: _('RSS post message goes here'),
    actions:
    {
      links:
      [
        title: _('URL'),
        external: true
      ]
    }
  }
]

blueprints.each { |blueprint| UINotifications::Seed.new(blueprint).configure }
