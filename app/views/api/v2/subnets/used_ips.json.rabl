object @subnet

extends "api/v2/subnets/show"

node :used_ips do |subnet|
  subnet.ipamservice.try(:used_ips)
end
