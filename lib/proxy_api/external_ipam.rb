require 'uri'

module ProxyAPI
  class ExternalIpam < ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + "/ipam"
      super args
    end

    # Queries External IPAM and retrieves the next available IP address for the given subnet.
    # The IP returned is NOT reserved in External IPAM database. It is however written to an in-memory,
    # thread safe cache, on the proxy side, with the subnet CIDR/mac address as the key(see
    # IP cache structure below). This will prevent the same IP being suggested for different mac addresses,
    # and will handle race condition scenarios where multiple hosts are being provisioned simultaneously.
    #
    # Groups of subnets are cached under the External IPAM Group name. "IPAM Group" in the example below is
    # the group name. For subnets that have an External IPAM group specified(e.g. "IPAM Group"),
    # the IP's/mac are cached under the "IPAM Group" key. If External IPAM group is not defined, then they
    # are cached under a "" key.
    #
    # The IP address is only actually reserved in the External IPAM database upon successful host
    # and/or interface creation.
    #
    # In-memory IP cache structure(IPv4 and IPv6):
    # ===============================
    # {
    #   "": {
    #     "100.55.55.0/24":{
    #       "00:0a:95:9d:68:10": {"ip": "100.55.55.1", "timestamp": "2019-09-17 12:03:43 -D400"}
    #     },
    #   },
    #   "IPAM Group": {
    #     "123.11.33.0/24":{
    #       "00:0a:95:9d:68:33": {"ip": "123.11.33.1", "timestamp": "2019-09-17 12:04:43 -0400"},
    #       "00:0a:95:9d:68:34": {"ip": "123.11.33.2", "timestamp": "2019-09-17 12:05:48 -0400"},
    #       "00:0a:95:9d:68:35": {"ip": "123.11.33.3", "timestamp:: "2019-09-17 12:06:50 -0400"}
    #     }
    #   },
    #   "Another IPAM Group": {
    #     "185.45.39.0/24":{
    #       "00:0a:95:9d:68:55": {"ip": "185.45.39.1", "timestamp": "2019-09-17 12:04:43 -0400"},
    #       "00:0a:95:9d:68:56": {"ip": "185.45.39.2", "timestamp": "2019-09-17 12:05:48 -0400"}
    #     }
    #   }
    # }
    #
    # Params: 1. subnet:           The IPv4 or IPv6 subnet CIDR. (Examples: IPv4 - "100.10.10.0/24", IPv6 - "2001:db8:abcd:12::/124")
    #         2. mac:              The mac address of the interface obtaining the IP address for
    #         3. group(optional):  The group in External IPAM that the subnet belongs to (e.g. 'Section' in
    #                              in phpIPAM, or 'VRF' in Netbox)
    #
    # Responses:
    #   Responses if success:
    #     IPv4: {"data": "100.55.55.3"}
    #     IPv6: {"data": "2001:db8:abcd:12::1"}
    #   Response if missing required params:
    #     {"error": ["A 'cidr' parameter for the subnet must be provided(e.g. 100.10.10.0/24)","A 'mac' address must be provided(e.g. 00:0a:95:9d:68:10)"]}
    #   Response if subnet does not exist:
    #     {"error": "Subnet not found in External IPAM."}
    #   Response if there are no free addresses:
    #     {"error": "No free addresses found"}
    #   Response if can't connect to External IPAM server
    #     {"error": "Unable to connect to External IPAM server"}
    def next_ip(subnet, mac, group = "")
      raise "subnet cannot be nil" if subnet.nil?
      raise "mac address cannot be nil" if mac.nil?
      response = parse get("/subnet/#{subnet}/next_ip?mac=#{mac}&group=#{URI.escape(group.to_s)}")
      raise(response['error']) if response['error'].present?
      response['data']
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to retrieve the next available IP for subnet %{subnet} External IPAM."), subnet: subnet)
    end

    # Adds an IP address to the specified subnet in External IPAM. This will reserve the IP in the
    # External IPAM database. If group is specified, the IP will be added to the subnet within the
    # given group.
    #
    # Params: 1. ip:               IP address to be added
    #         2. subnet:           The IPv4 or IPv6 subnet CIDR. (Examples: IPv4 - "100.10.10.0/24",
    #                              IPv6 - "2001:db8:abcd:12::/124")
    #         3. group(optional):  The name of the External IPAM group containing the subnet.
    #
    # Returns: true if IP was added successfully to External IPAM, otherwise false
    #
    # Responses:"
    #   Response if success:
    #     201
    #   Response if IP already reserved:
    #     {"error": "IP address already exists"}
    #   Response if subnet error:
    #     {"error": "Subnet not found in External IPAM"}
    #   Response if missing required params:
    #     {"error": ["A 'cidr' parameter for the subnet must be provided(e.g. 100.10.10.0/24)","Missing 'ip' parameter. An IPv4 address must be provided(e.g. 100.10.10.22)"]}
    #   Response if can't connect to External IPAM server
    #     {"error": "Unable to connect to External IPAM server"}
    def add_ip_to_subnet(ip, subnet, group = "")
      raise "subnet cannot be nil" if subnet.nil?
      raise "ip cannot be nil" if ip.nil?
      response = parse post({}, "/subnet/#{subnet}/#{ip}?group=#{URI.escape(group.to_s)}")
      raise(response['error']) if response.is_a?(Hash) && response['error'].present?
      response
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to add IP %{ip} to the subnet %{subnet} in External IPAM."), ip: ip, subnet: subnet)
    end

    # Get a list of groups from External IPAM. A group is a logical grouping of subnets/ips.
    #
    # Params:  None
    #
    # Returns: An array of groups on success, or a hash with a "error" key
    #          containing error on failure.
    #
    # Responses:
    #   Response if success:
    #     {[
    #       {name":"Test Group","description": "A Test Group"},
    #       {name":"Awesome Group","description": "A totally awesome Group"}
    #     ]}
    #   Response if no groups exist:
    #     []
    #   Response if groups are not supported:
    #     {"error": "Groups are not supported"}
    #   Response if can't connect to External IPAM server
    #     {"error": "Unable to connect to External IPAM server"}
    def get_groups
      response = parse get("/groups")
      raise(response['error']) if response.is_a?(Hash) && response['error'].present?
      response
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to obtain groups from External IPAM."))
    end

    # Get a group from External IPAM. A group is a logical grouping of subnets/ips (e.g. 'Section' in
    # in phpIPAM, or 'VRF' in Netbox)
    #
    # Params:   1. group:     The name of the External IPAM group
    #
    # Responses:
    #   Response if success:
    #     {"name":"Awesome Group", "description": "Awesome Group"}
    #   Response if group doesn't exist:
    #     {"error": "Group not found in External IPAM"}
    #   Response if groups are not supported:
    #     {"error": "Groups are not supported"}
    #   Response if can't connect to External IPAM server
    #     {"error": "Unable to connect to External IPAM server"}
    def get_group(group)
      raise "group must be provided" if group.blank?
      response = parse get("/groups/#{URI.escape(group)}")
      raise(response['error']) if response['error'].present?
      response
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to obtain group %{group} from External IPAM."), group: group)
    end

    # Get a list of subnets for the given External IPAM group.
    #
    # Params:  1. group:     The name of the External IPAM group containing the subnet.
    #
    # Responses:
    #   Response if success:
    #   {[
    #     {subnet":"100.10.10.0","mask":"24","description":"Test Subnet 1"},
    #     {subnet":"100.20.20.0","mask":"24","description":"Test Subnet 2"}
    #   ]}
    #   Response if groups not supported:
    #     {"error": "Groups are not supported"}
    #   Response if no subnets exist in group.
    #     {"error": "Subnet not found in External IPAM"}
    #   Response if group not found:
    #     {"error": "Group not found in External IPAM"}
    #   Response if can't connect to External IPAM server
    #     {"error": "Unable to connect to External IPAM"}
    def get_subnets_by_group(group)
      raise "group must be provided" if group.blank?
      response = parse get("/groups/#{URI.escape(group)}/subnets")
      raise(response['error']) if response.is_a?(Hash) && response['error'].present?
      response
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to obtain subnets in group %{group} from External IPAM."), group: group)
    end

    # Returns an array of subnets from External IPAM matching the given subnet.
    #
    # Params:  1. subnet:           The IPv4 or IPv6 subnet CIDR. (Examples: IPv4 - "100.10.10.0/24",
    #                               IPv6 - "2001:db8:abcd:12::/124")
    #          2. group(optional):  The name of the External IPAM group containing the subnet.
    #
    # Responses:
    #   Response if subnet(s) exists:
    #     {"subnet": "44.44.44.0", "description": "", "mask":"29"}
    #   Response if subnet not exists:
    #     {"error": "No subnets found"}
    #   Response if groups not supported(only checked if a group is specified):
    #     {"error": "Groups are not supported"}
    #   Response if can't connect to External IPAM server
    #     {"error": "Unable to connect to External IPAM server"}
    def get_subnet(subnet, group = "")
      raise "subnet cannot be nil" if subnet.nil?
      response = parse get("/subnet/#{subnet}?group=#{URI.escape(group.to_s)}")
      raise(response['error']) if response['error'].present?
      response
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to obtain subnet %{subnet} from External IPAM."), subnet: subnet)
    end

    # Checks whether an IP address has been reserved in External IPAM.
    #
    # Inputs: 1. ip:               IP address to be checked
    #         2. subnet:           The IPv4 or IPv6 subnet CIDR. (Examples: IPv4 - "100.10.10.0/24",
    #                              IPv6 - "2001:db8:abcd:12::/124")
    #         3. group(optional):  The name of the External IPAM group containing the subnet to pull IP from
    #
    # Responses:
    #   Response if IP is reserved:
    #     true
    #   Response if IP address is available
    #     false
    #   Response if missing required parameters:
    #     {"error": ["A 'cidr' parameter for the subnet must be provided(e.g. 100.10.10.0/24)", "Missing 'ip' parameter. An IPv4 address must be provided(e.g. 100.10.10.22)"]}
    #   Response if subnet not exists:
    #     {"error": "Subnet not found in External IPAM"}
    #   Response if groups not supported(only checked if a group is specified):
    #     {"error": "Groups are not supported"}
    #   Response if can't connect to External IPAM server
    #     {"error": "Unable to connect to External IPAM server"}
    def ip_exists(ip, subnet, group = "")
      raise "subnet cannot be nil" if subnet.nil?
      raise "ip cannot be nil" if ip.nil?
      response = parse get("/subnet/#{subnet}/#{ip}?group=#{URI.escape(group.to_s)}")
      raise(response['error']) if response.is_a?(Hash) && response['error'].present?
      response
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to obtain IP address for subnet %{subnet} in External IPAM."), subnet: subnet)
    end

    # Deletes an IP address from a given subnet in External IPAM.
    #
    # Inputs: 1. ip:               IP address to be freed up
    #         2. subnet:           The IPv4 or IPv6 subnet CIDR. (Examples: IPv4 - "100.10.10.0/24",
    #                              IPv6 - "2001:db8:abcd:12::/124")
    #         3. group(optional):  The name of the External IPAM group containing the subnet.
    #
    # Responses:
    #   Response if success:
    #     200
    #   Response if subnet error:
    #     {"error": "The specified subnet does not exist in External IPAM."}
    #   Response if IP already deleted:
    #     {"error": "Unable to delete IP from External IPAM"}
    #   Response if groups not supported(only checked if a group is specified):
    #     {"error": "Groups are not supported"}
    #   Response if can't connect to External IPAM server
    #     {"error": "Unable to connect to External IPAM server"}
    def delete_ip_from_subnet(ip, subnet, group = "")
      raise "subnet cannot be nil" if subnet.nil?
      raise "ip cannot be nil" if ip.nil?
      response = parse delete("/subnet/#{subnet}/#{ip}?group=#{URI.escape(group.to_s)}")
      raise(response['error']) if response.is_a?(Hash) && response['error'].present?
      response
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to delete IP %{ip} from the subnet %{subnet} in External IPAM."), ip: ip, subnet: subnet)
    end
  end
end
