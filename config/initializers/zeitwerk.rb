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
    'ipam' => 'IPAM',
    'ssh' => 'SSH',
    'ssh_provision' => 'SSHProvision',
    'ssh_execution_provider' => 'SSHExecutionProvider',
    'keep_current_request_id' => 'KeepCurrentRequestID'
  )
end
# Rails.autoloaders.log!
