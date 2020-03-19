# Proxy features
["TFTP", "DNS", "DHCP", "Puppet", "Puppet CA", "BMC", "Realm", "Facts", "Logs", "HTTPBoot", "External IPAM"].each do |input|
  f = Feature.where(:name => input).first_or_create
  raise "Unable to create proxy feature: #{format_errors f}" if f.nil? || f.errors.any?
end
