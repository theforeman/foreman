object @subnet

extends "api/v2/subnets/base"

attributes :network, :mask, :priority, :vlanid, :gateway, :dns_primary, :dns_secondary,
           :from, :to, :cidr, :created_at, :updated_at

child :dhcp => :dhcp do
  extends "api/v2/smart_proxies/base"
end

child :tftp => :tftp do
  extends "api/v2/smart_proxies/base"
end

child :dns => :dns do
  extends "api/v2/smart_proxies/base"
end
