object @subnet

extends "api/v2/subnets/main"

child :dhcp => :dhcp do
  attributes :id, :name, :url
end

child :tftp => :tftp do
  attributes :id, :name, :url
end

child :dns => :dns do
  attributes :id, :name, :url
end