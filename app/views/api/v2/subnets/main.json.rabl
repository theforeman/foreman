object @subnet

extends "api/v2/subnets/base"

attributes :network, :mask, :priority, :vlanid,
  :gateway, :dns_primary, :dns_secondary, :from, :to, :domain_ids,
  :dns_id, :dhcp_id, :tftp_id, :cidr
