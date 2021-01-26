Rails.autoloaders.each do |autoloader|
  autoloader.inflector = Zeitwerk::Inflector.new
  autoloader.inflector.inflect(
    'ui' => 'UI',
    'proxy_api' => 'ProxyAPI',
    'sti' => 'STI',
    'dhcp' => 'DHCP',
    'dns' => 'DNS',
    'tftp' => 'TFTP',
    'external_ipam' => 'ExternalIPAM',
    'bmc' => 'BMC',
    'ui_notifications' => 'UINotifications',
    'ssh_provision' => 'SSHProvision',
    'ipam' => 'IPAM',
    'sso' => 'SSO',
    'ec2' => 'EC2',
    'gce' => 'GCE',
    'aaaa_record' => 'AAAARecord',
    'aix' => 'AIX',
    'ptr4_record' => 'PTR4Record',
    'ptr6_record' => 'PTR6Record',
    'nxos' => 'NXOS',
    'vrp' => 'VRP',
  )
end
