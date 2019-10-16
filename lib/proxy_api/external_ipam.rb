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
    # The IP address is only actually reserved in the External IPAM database upon successful host
    # and/or interface creation.
    #
    # In-memory IP cache structure:
    # ===============================
    #   "100.55.55.0/24":{
    #      "00:0a:95:9d:68:10": {"ip": "100.55.55.1", "timestamp": "2019-09-17 12:03:43 -D400"}
    #   },
    #   "123.11.33.0/24":{
    #      "00:0a:95:9d:68:33": {"ip": "123.11.33.1", "timestamp": "2019-09-17 12:04:43 -0400"}
    #      "00:0a:95:9d:68:34": {"ip": "123.11.33.2", "timestamp": "2019-09-17 12:05:48 -0400"}
    #      "00:0a:95:9d:68:35": {"ip": "123.11.33.3", "timestamp:: "2019-09-17 12:06:50 -0400"}
    #   }
    # }
    #
    # Params: 1. subnet:  The Foreman subnet object
    #         2. mac:     The mac address of the interface obtaining the IP address for
    #
    # Returns: A hash with next available IP in the "data" field, or a hash with "error" on failure
    #
    # Examples:
    #   Response if success:
    #     {"code": 200, "success": true, "data": "100.55.55.3", "time": 0.012}
    #   Response if missing required params:
    #     {"error": ["A 'cidr' parameter for the subnet must be provided(e.g. 100.10.10.0/24)","A 'mac' address must be provided(e.g. 00:0a:95:9d:68:10)"]}
    #   Response if subnet error:
    #     {"error": "The specified subnet does not exist in External IPAM."}
    #   Response if there are no free addresses:
    #     {"error": "No free addresses found"}
    #   Response if can't connect to External IPAM server
    #     {"error": "Unable to connect to External IPAM server"}
    def next_ip(subnet, mac)
      raise "subnet.network cannot be nil" unless subnet.network.present?
      parse get("/next_ip?cidr=#{subnet.network_address}&mac=#{mac}")
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to retrieve the next available IP for subnet %s from External IPAM."), subnet.network_address)
    end

    # Adds an IP address to the specified subnet in External IPAM. This will reserve the IP in the
    # External IPAM database.
    #
    # Params: 1. ip:     IP address to be added
    #         2. subnet: The Foreman subnet object
    #
    # Returns: A hash with a message of "Address created" on success, or a hash with "error" on failure
    #
    # Examples:
    #   Response if success:
    #     {"code": 201, "success": true, "message": "Address created", "id": "156", "time": 0.015}
    #   Response if IP already reserved:
    #     {"code": 409, "success": false, "message": "IP address already exists", "time": 0.006}
    #   Response if subnet error:
    #     {"error": "The specified subnet does not exist in External IPAM."}
    #   Response if missing required params:
    #     {"error": ["A 'cidr' parameter for the subnet must be provided(e.g. 100.10.10.0/24)","Missing 'ip' parameter. An IPv4 address must be provided(e.g. 100.10.10.22)"]}
    #   Response if can't connect to External IPAM server
    #     {"error": "Unable to connect to External IPAM server"}
    def add_ip_to_subnet(ip, subnet)
      raise "subnet.network cannot be nil" unless subnet.network.present?
      parse(post({:ip => ip, :cidr => subnet.network_address}, "/add_ip_to_subnet"))
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to add IP %s to the subnet %s in External IPAM."), ip, subnet.network_address)
    end

    # Get a list of sections from External IPAM. A section in phpIPAM is a logical grouping of subnets/ips.
    #
    # Params: None
    #
    # Returns: An array of sections on success, or a hash with "error" otherwise.
    #
    # Examples
    #   Response if success: [
    #     {"id":"4","name":"Test Section","description":"A Test Section"},
    #     {"id":"5","name":"Awesome Section","description":"A totally awesome Section"}
    #   ]
    #   Response if no sections exist:
    #     {"code":200, "success":true, "message": "No sections available", "time": 0.004, "data": []}
    #   Response if can't connect to External IPAM server
    #     {"error": "Unable to connect to External IPAM server"}
    def get_sections
      parse get("/sections")
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to obtain sections from External IPAM."))
    end

    # Get a list of subnets for the given External IPAM section.
    #
    # Params:  1. section_name: The name of the External IPAM section
    #
    # Returns: An array of subnets on success, or a hash with "error" otherwise.
    #
    # Examples:
    #   Response if success: [
    #     {"id":"9","subnet":"100.10.10.0","mask":"24","sectionId":"5","description":"Test Subnet 1"},
    #     {"id":"10","subnet":"100.20.20.0","mask":"24","sectionId":"5","description":"Test Subnet 2"}
    #   ]
    #   Response if section not found:
    #     {"error": "Section not found in External IPAM."}
    #   Response if no subnets exist in section.
    #     {"code": 200, "success": true, "data": [], "time": 0.007}
    #   Response if can't connect to External IPAM server
    #     {"error": "Unable to connect to External IPAM server"}
    def get_subnets_by_section(section_name)
      raise "section_name must be provided" if section_name.blank?
      parse get("/sections/#{URI.encode(section_name)}/subnets")
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to obtain subnets in section/group %s from External IPAM."), section_name)
    end

    # Returns an array of subnets from External IPAM. If the "Require unique subnets" setting in External IPAM
    # is enabled, this will return one subnet(or zero if not exists). If this setting is disabled(i.e. you can
    # have duplicate subnets and IP's), then it is possible to get more than one.
    #
    # Params:  1. subnet: The Foreman subnet object
    #
    # Returns: A subnet with "data" key, or a hash with "error" otherwise
    #
    # Examples:
    #   Response if subnet(s) exists:
    #     {"code": 200, "success": true, "data": [
    #       {"id": "32", "subnet": "10.10.10.0", "description": "Test", "mask": "29"}
    #     ], "time": 0.007}
    #   Response if subnet not exists:
    #     {"error": "No subnets found"}
    #   Response if can't connect to External IPAM server
    #     {"error": "Unable to connect to External IPAM server"}
    def get_subnet(subnet)
      raise "subnet.network cannot be nil" unless subnet.network.present?
      parse get("/get_subnet?cidr=#{subnet.network_address}")
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to obtain subnet %s from External IPAM."), subnet.network_address)
    end

    # Checks whether an IP address has already been reserved in External IPAM.
    #
    # Inputs: 1. ip:     IP address to be checked
    #         2. subnet: The Foreman subnet object
    #
    # Returns: A hash with "data" key if IP already reserved, a hash with a message of "No addresses found" if
    #          IP is available, or a hash with "error" otherwise
    #
    # Examples:
    #   Response if IP is already reserved:
    #     {"code": 200, "success": true, "data": [{"id":"157","subnetId":"32","ip":"10.10.10.1","is_gateway":null,"description":null,"hostname":null,"mac":null,"owner":null,"tag":"2","deviceId":null,"location":null,"port":null,"note":null,"lastSeen":null,"excludePing":"0","PTRignore":"0","PTR":"0","firewallAddressObject":null,"editDate":null,"customer_id":null}],"time":0.008}
    #   Response if IP address is available
    #     {"code": 200, "success": false, "message": "No addresses found", "time": 0.007}
    #   Response if missing required parameters:
    #     {"error": ["A 'cidr' parameter for the subnet must be provided(e.g. 100.10.10.0/24)", "Missing 'ip' parameter. An IPv4 address must be provided(e.g. 100.10.10.22)"]}
    #   Response if subnet not exists:
    #     {"code": 200, "success": false, "message": "No subnets found", "time": 0.007}
    #   Response if can't connect to External IPAM server
    #     {"error": "Unable to connect to External IPAM server"}
    def ip_exists(ip, subnet)
      raise "subnet.network cannot be nil" unless subnet.network.present?
      parse get("/ip_exists?cidr=#{subnet.network_address}&ip=#{ip}")
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to obtain IP address for subnet_id %s from External IPAM."), subnet['id'].to_s)
    end

    # Frees up an IP address from a given subnet in External IPAM.
    #
    # Inputs: 1. ip:     IP address to be freed up
    #         2. subnet: The Foreman subnet object
    #
    # Returns: A hash with "message" on success, or a hash with "error" on failure
    #
    # Examples:
    #   Response if success:
    #     {"code": 200, "success": true, "message": "Address deleted", "time": 0.012}
    #   Response if subnet error:
    #     {"error": "The specified subnet does not exist in External IPAM."}
    #   Response if IP already deleted:
    #     {"code": 200, "success": false, "message": "No addresses found", "time": 0.006}
    #   Response if can't connect to External IPAM server
    #     {"error": "Unable to connect to External IPAM server"}
    def delete_ip_from_subnet(ip, subnet)
      raise "subnet.network cannot be nil" unless subnet.network.present?
      parse(post({:ip => ip, :cidr => subnet.network_address}, "/delete_ip_from_subnet"))
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to delete IP %s from the subnet %s in External IPAM."), ip, subnet.network_address)
    end
  end
end
