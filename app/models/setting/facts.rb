class Setting::Facts < Setting
  # facts which change way too often
  IGNORED_FACTS = [
    'load_averages::*',
    'memory::system::capacity',
    'memory::system::used*',
    'memory::system::available*',
    'memory::swap::capacity',
    'memory::swap::used*',
    'memory::swap::available*',
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

  DEFAULT_EXCLUDED_FACTS = IGNORED_INTERFACES + IGNORED_FACTS


  def self.tool_specific
    @tool_specific ||= {}
  end

  def self.add_tool_specific(tool_name, settings)
    tool_specific[tool_name.to_sym] ||= []
    tool_specific[tool_name.to_sym].concat(settings)
  end

  add_tool_specific 'puppet', [
    set('default_puppet_environment', N_("Foreman will default to this puppet environment if it cannot auto detect one"), "production", N_('Default Puppet environment'), nil, { :collection => proc { Hash[Environment.all.map { |env| [env[:name], env[:name]] }] } }),
    set('enc_environment', N_("Foreman will explicitly set the puppet environment in the ENC yaml output. This will avoid conflicts between the environment in puppet.conf and the environment set in Foreman"), true, N_('ENC environment')),
    set('update_environment_from_facts', N_("Foreman will update a host's environment from its facts"), false, N_('Update environment from facts')),
    set('ignore_puppet_facts_for_provisioning', N_("Stop updating IP address and MAC values from Puppet facts (affects all interfaces)"), false, N_('Ignore Puppet facts for provisioning')),
  ]

  def self.update_subnets_from_facts_types
    {
      'all' => _('All'),
      'provisioning' => _('Provisioning only'),
      'none' => _('None'),
    }
  end

  def self.default_settings
    [
      set('create_new_host_when_facts_are_uploaded', N_("Foreman will create the host when new facts are received"), true, N_('Create new host when facts are uploaded')),
      set('default_location', N_("Hosts created from uploaded facts that did not send a location fact will be placed in this location"), '', N_('Default location'), nil, { :collection => proc { Hash[Location.all.map { |loc| [loc[:title], loc[:title]] }] } }),
      set('default_organization', N_("Hosts created from uploaded facts that did not send a organization fact will be placed in this organization"), '', N_('Default organization'), nil, {:collection => proc { Hash[Organization.all.map { |org| [org[:title], org[:title]] }] } }),
      set('location_fact', N_("Hosts created from uploaded facts will be placed in the location this fact dictates. The content of this fact should be the full label of the location."), 'foreman_location', N_('Location fact')),
      set('organization_fact', N_("Hosts created from uploaded facts will be placed in the organization this fact dictates. The content of this fact should be the full label of the organization."), 'foreman_organization', N_('Organization fact')),
      set('update_subnets_from_facts', N_("Foreman will update a Host's subnet from its facts"), 'none', N_('Update subnets from facts'), nil, { :collection => proc { update_subnets_from_facts_types } }),
      set('update_hostgroup_from_facts', N_("Foreman will update a Host's Hostgroup from its facts"), true, N_('Update hostgroup from facts')),
      set('ignore_facts_for_operatingsystem', N_("Stop updating Operating System from facts"), false, N_('Ignore facts for operating system')),
      set('ignore_facts_for_domain', N_("Stop updating domain values from facts"), false, N_('Ignore facts for domain')),
      set('ignored_interface_identifiers', N_("Ignore interfaces that match these values during facts importing, you can use * wildcard to match names with indexes e.g. macvtap*"), IGNORED_INTERFACES, N_('Ignore interfaces with matching identifier')),
      set(
        'excluded_facts',
        N_("Exclude pattern for all types of imported facts (puppet, ansible, rhsm). Those facts won't be stored in foreman's database. You can use * wildcard to match names with indexes e.g. ignore* will filter out ignore, ignore123 as well as a::ignore or even a::ignore123::b"),
        DEFAULT_EXCLUDED_FACTS,
        N_('Exclude pattern for facts stored in foreman')
      ),
    ] + tool_specific.values.flatten
  end

  def self.humanized_category
    N_('Facts')
  end
end
