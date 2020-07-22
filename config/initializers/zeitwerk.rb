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
    'ipam' => 'IPAM'
  )
end
Rails.autoloaders.log!
