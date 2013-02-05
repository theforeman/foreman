object @subnet

attributes :id, :name, :network, :mask, :priority, :vlanid,
  :gateway, :dns_primary, :dns_secondary, :from, :to, :domain_ids,
  :dns_id, :dhcp_id, :tftp_id, :cidr

child :dhcp => :dhcp do
  attributes :id, :name, :url
end

child :tftp => :tftp do
  attributes :id, :name, :url
end

child :dns => :dns do
  attributes :id, :name, :url
end