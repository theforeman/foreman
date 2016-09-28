object @subnet

extends "api/v2/subnets/base"
extends "api/v2/smart_proxies/children_nodes"

attributes :network, :network_type, :cidr, :mask, :priority, :vlanid, :gateway,
           :dns_primary, :dns_secondary,
           :from, :to, :created_at, :updated_at, :ipam, :boot_mode
