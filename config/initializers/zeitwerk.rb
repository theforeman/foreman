Rails.autoloaders.main.inflector.inflect(
  'ui' => 'UI',
  'proxy_api' => 'ProxyAPI',
  'sti' => 'STI',
  'dhcp' => 'DHCP',
  'dns' => 'DNS',
  'tftp' => 'TFTP',
  'external_ipam' => 'ExternalIPAM',
  'bmc' => 'BMC',
  'ui_notifications' => 'UINotifications',
  'ipam' => 'IPAM',
  'ssh' => 'SSH',
  'ssh_provision' => 'SSHProvision',
  'ssh_execution_provider' => 'SSHExecutionProvider',
  'keep_current_request_id' => 'KeepCurrentRequestID',
  'ec2' => 'EC2',
  'aws' => 'AWS',
  'gce' => 'GCE',
  'aix' => 'AIX',
  'nxos' => 'NXOS',
  'vrp' => 'VRP',
  'sso' => 'SSO',
  'puppet_ca_certificate' => 'PuppetCACertificate',
  'url_resolver' => 'URLResolver',
  'ztp_record' => 'ZTPRecord',
  'aaaa_record' => 'AAAARecord',
  'ptr4_record' => 'PTR4Record',
  'ptr6_record' => 'PTR6Record'
)

Rails.autoloaders.main.ignore(
  Rails.root.join('lib/core_extensions.rb'),
  Rails.root.join('lib/generators')
)
Rails.autoloaders.once.ignore(
  Rails.root.join('app/registries/foreman/access_permissions.rb'),
  Rails.root.join('app/registries/foreman/settings.rb'),
  Rails.root.join('app/registries/foreman/settings')
)
