# Proxy features
[ "TFTP", "DNS", "DHCP", "Puppet", "Puppet CA", "BMC", "Chef Proxy" ].each do |input|
  f = Feature.find_or_create_by_name(input)
  raise "Unable to create proxy feature: #{format_errors f}" if f.nil? || f.errors.any?
end
