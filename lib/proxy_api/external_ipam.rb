require 'uri'

module ProxyAPI
  class ExternalIpam < ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + "/ipam"
      super args
    end

    # Retrieves the next available IP address for the specified subnet
    #
    # Inputs: 1. subnet(object): The Foreman subnet
    #         2. mac: The mac address of the interface obtaining the IP address for
    # Returns: Hash with "next_ip", or hash with "error"
    # Examples:
    #   Response if success:
    #     {"cidr":"100.20.20.0/24","next_ip":"100.20.20.11"}
    #   Response if error:
    #     {"error":"The specified subnet does not exist in external ipam."}
    def next_ip(subnet, mac)
      cidr = subnet.network + '/' + subnet.cidr.to_s if subnet.network.present?
      get("/next_ip?cidr=#{cidr}&mac=#{mac}")
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to retrieve the next available IP for subnet %s from External IPAM."), cidr)
    end

    # Adds an IP address to the specified subnet
    #
    # Inputs: 1. ip(string). IP address to be added.
    #         2. subnet(object): The Foreman subnet
    # Returns: Hash with "message" on success, or hash with "error"
    # Examples:
    #   Response if success:
    #     {"message":"IP 100.10.10.123 added to subnet 100.10.10.0/24 successfully."}
    #   Response if error:
    #     {"error":"The specified subnet does not exist in external ipam."}
    def add_ip_to_subnet(ip, subnet)
      cidr = subnet.network + '/' + subnet.cidr.to_s if subnet.network.present?
      parse(post({:ip => ip, :cidr => cidr}, "/add_ip_to_subnet"))
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to add IP %s to the subnet %s in External IPAM."), ip, cidr)
    end

    # Get a list of sections from external ipam
    #
    # Input: None
    # Returns: An array of sections on success, hash with "error" key otherwise
    # Examples
    #   Response if success: [
    #     {"id":"4","name":"Test Section","description":"A Test Section"},
    #     {"id":"5","name":"Awesome Section","description":"A totally awesome Section"}
    #   ]
    #   Response if error:
    #     {"error":"Unable to connect to external ipam server"}
    def get_sections
      get("/sections")
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to obtain sections from External IPAM."))
    end

    # Get a list of subnets for given external ipam section/group
    #
    # Input: group_name(string). The name of the external ipam section/group
    # Returns: Array of subnets(as json) on success, hash with error otherwise
    # Examples:
    #   Response if success:
    #     [
    #       {"id":"9","subnet":"100.10.10.0","mask":"24","sectionId":"5","description":"Test Subnet 1"},
    #       {"id":"10","subnet":"100.20.20.0","mask":"24","sectionId":"5","description":"Test Subnet 2"}
    #     ]
    #   Response if error:
    #     {"error":"Unable to connect to external ipam server"}
    def get_subnets(section_name)
      get("/sections/#{URI.encode(section_name)}/subnets")
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to obtain subnets in section/group %s from External IPAM."), section_name)
    end

    # Gets a subnet from external ipam.
    #
    # Input:   subnet(object): The Foreman subnet
    # Returns: JSON object with "data" key if exists, otherwise JSON object with "message" key
    #          containing an error message.
    # Examples:
    #   Response if subnet exists:
    #     [{"id":"9","subnet":"100.20.20.0","description":"Test Subnet","mask":"24"}]
    #   Response if subnet not exists:
    #     {"error": "No subnets found"}
    def get_subnet(subnet)
      cidr = subnet.network + '/' + subnet.cidr.to_s if subnet.network.present?
      get("/get_subnet?cidr=#{cidr}")
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to obtain subnet %s from External IPAM."), cidr)
    end

    # Checks whether an IP address has already been taken in external ipam.
    #
    # Inputs: 1. ip(string). IP address to be checked.
    #         2. subnet(object): The Foreman subnet object
    # Returns: JSON object with 'exists' field being either true or false
    # Example:
    #   Response if exists:
    #     {"ip":"100.20.20.18","exists": true}
    #   Response if not exists:
    #     {"ip":"100.20.20.18","exists": false}
    def ip_exists(ip, subnet)
      cidr = subnet.network + '/' + subnet.cidr.to_s if subnet.network.present?
      get("/ip_exists?cidr=#{cidr}&ip=#{ip}")
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to obtain IP address for subnet_id %s from External IPAM."), subnet['id'].to_s)
    end

    # Deletes IP address from a given subnet
    #
    # Inputs: 1. ip(string). IP address to be checked.
    #         2. subnet(object): The Foreman subnet
    # Returns: JSON object with "message" on success, or "error" if error
    # Example:
    #   Response if success:
    #     {"message": "IP 100.20.20.18 deleted from subnet 100.20.20.0/24 successfully."}
    #   Response if error:
    #     {"error": "The specified subnet does not exist in external ipam."}
    def delete_ip_from_subnet(ip, subnet)
      cidr = subnet.network + '/' + subnet.cidr.to_s if subnet.network.present?
      parse(post({:ip => ip, :cidr => cidr}, "/delete_ip_from_subnet"))
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to delete IP %s from the subnet %s in External IPAM."), ip, cidr)
    end

    private

    # TODO: Use ProxyAPI::Resource.parse instead for GET(for consistency), once it has been
    #       refactored to handle error messages better
    def get(path, body = nil)
      uri = URI.parse(@url + path)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if @url =~ /^https/i
      response = http.get(uri.request_uri)
      JSON.parse(response.body)
    end
  end
end
