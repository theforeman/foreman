Foreman::SettingManager.define(:foreman) do
  category(:facts, N_('Facts')) do
    # facts which change way too often
    IGNORED_FACTS = [
      'load_averages::*',
      'memory::swap::available*',
      'memory::swap::capacity',
      'memory::swap::used*',
      'memory::system::available*',
      'memory::system::capacity',
      'memory::system::used*',
      'memoryfree',
      'memoryfree_mb',
      'swapfree',
      'swapfree_mb',
      # uptime_seconds is not here since the boot time fact is derived from it
      'uptime_hours',
      'uptime_days',
    ].freeze

    IGNORED_INTERFACES = [
      'lo',
      'en*v*',
      'usb*',
      'vnet*',
      'macvtap*',
      ';vdsmdummy;',
      'veth*',
      'docker*',
      'tap*',
      'qbr*',
      'qvb*',
      'qvo*',
      'qr-*',
      'qg-*',
      'vlinuxbr*',
      'vovsbr*',
      'br-int',
    ].freeze

    setting('create_new_host_when_facts_are_uploaded',
      type: :boolean,
      description: N_("Foreman will create the host when new facts are received"),
      default: true,
      full_name: N_('Create new host when facts are uploaded'))
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
    setting('update_hostgroup_from_facts',
      type: :boolean,
      description: N_("Foreman will update a host's hostgroup from its facts"),
      default: true,
      full_name: N_('Update hostgroup from facts'))
    setting('ignore_facts_for_operatingsystem',
      type: :boolean,
      description: N_("Stop updating Operating System from facts"),
      default: false,
      full_name: N_('Ignore facts for operating system'))
    setting('ignore_facts_for_domain',
      type: :boolean,
      description: N_("Stop updating domain values from facts"),
      default: false,
      full_name: N_('Ignore facts for domain'))
    setting('update_subnets_from_facts',
      type: :string,
      description: N_("Foreman will update a host's subnet from its facts"),
      default: 'none',
      full_name: N_('Update subnets from facts'),
      collection: proc { { 'all' => _('All'), 'provisioning' => _('Provisioning only'), 'none' => _('None') } })
    setting('ignore_puppet_facts_for_provisioning',
      type: :boolean,
      description: N_("Stop updating IP and MAC address values from facts (affects all interfaces)"),
      default: false,
      full_name: N_('Ignore interfaces facts for provisioning'))
    setting('ignored_interface_identifiers',
      type: :array,
      description: N_("Skip creating or updating host network interfaces objects with identifiers matching these values from incoming facts. You can use * wildcard to match identifiers with indexes e.g. macvtap*. The ignored interfaces raw facts will be still stored in the DB, see the 'Exclude pattern' setting for more details."),
      default: IGNORED_INTERFACES,
      full_name: N_('Ignore interfaces with matching identifier'))
    setting('excluded_facts',
      type: :array,
      description: N_("Exclude pattern for all types of imported facts (puppet, ansible, rhsm). Those facts won't be stored in foreman's database. You can use * wildcard to match names with indexes e.g. ignore* will filter out ignore, ignore123 as well as a::ignore or even a::ignore123::b"),
      default: IGNORED_INTERFACES + IGNORED_FACTS,
      full_name: N_('Exclude pattern for facts stored in foreman'))
  end
end

Foreman::SettingManager.define(:puppet) do
  all_environments = proc do
    env_klass = 'ForemanPuppet::Environment'.safe_constantize
    env_klass ? Hash[env_klass.all.map { |env| [env[:name], env[:name]] }] : {}
  end
  category(:facts, N_('Facts')) do
    setting('default_puppet_environment',
      type: :string,
      description: N_("Foreman will default to this puppet environment if it cannot auto detect one"),
      default: "production",
      full_name: N_('Default Puppet environment'),
      collection: all_environments)
    setting('enc_environment',
      type: :boolean,
      description: N_("Foreman will explicitly set the puppet environment in the ENC yaml output. This will avoid conflicts between the environment in puppet.conf and the environment set in Foreman"),
      default: true,
      full_name: N_('ENC environment'))
    setting('update_environment_from_facts',
      type: :boolean,
      description: N_("Foreman will update a host's environment from its facts"),
      default: false,
      full_name: N_('Update environment from facts'))
  end
end
