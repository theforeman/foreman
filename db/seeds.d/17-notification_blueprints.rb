blueprints = [
  {
    group: _('Hosts'),
    name: 'host_build_completed',
    message: _('%{subject} has been provisioned successfully'),
    level: 'success',
    actions:
    {
      links:
      [
        path_method: :host_path,
        title: _('Details')
      ]
    }
  },
  {
    group: _('Hosts'),
    name: 'host_destroyed',
    message: _('%{subject} has been deleted successfully'),
    level: 'info'
  },
  {
    group: _('Hosts'),
    name: 'host_missing_owner',
    message: _('%{subject} has no owner set'),
    level: 'warning',
    actions:
    {
      links:
      [
        path_method: :edit_host_path,
        title: _('Update host')
      ]
    }
  }
]

blueprints.each { |blueprint| UINotifications::Seed.new(blueprint).configure }
