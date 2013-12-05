object @subnet

extends "api/v2/subnets/main"

child :dhcp => :dhcp do
  extends "api/v2/smart_proxies/base"
end

child :tftp => :tftp do
  extends "api/v2/smart_proxies/base"
end

child :dns => :dns do
  extends "api/v2/smart_proxies/base"
end