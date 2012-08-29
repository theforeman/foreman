object @subnet

attributes :id, :name, :network, :mask, :priority, :vlanid,
  :gateway, :dns_primary, :dns_secondary, :from, :to, :domain_ids

child :dhcp => :dhcp do
  attributes :id, :name, :url
end

child :tftp => :tftp do
  attributes :id, :name, :url
end

child :dns => :dns do
  attributes :id, :name, :url
end