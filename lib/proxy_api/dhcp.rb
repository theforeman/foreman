module ProxyAPI
  class DHCP < ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + "/dhcp"
      super args
    end

    # Retrieve the Server's subnets
    # Returns: Array of Hashes or false
    # Example [{"network":"192.168.11.0","netmask":"255.255.255.0"},{"network":"192.168.122.0","netmask":"255.255.255.0"}]
    def subnets
      parse get
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to retrieve DHCP subnets"))
    end

    def subnet(subnet)
      parse get(subnet)
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to retrieve DHCP subnet"))
    end

    def unused_ip(subnet, mac = nil)
      params = {}
      params[:mac] = mac if mac.present?

      if subnet.from.present? && subnet.to.present?
        params[:from] = subnet.from
        params[:to] = subnet.to
      end
      if params.any?
        params = params.map { |e| e.join("=") }.join("&")
      else
        params = ""
      end
      parse get("#{subnet.network}/unused_ip", query: params)
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to retrieve unused IP"))
    end

    # Retrieves a DHCP entry for a mac
    # [+subnet+] : String in dotted decimal format
    # [+mac+]    : String in coloned sextuplet format
    # Returns    : Hash or false
    def record(subnet, mac)
      response = parse(get("#{subnet}/mac/#{mac}"))
      attrs = response.merge(:network => subnet, :proxy => self)
      if response.keys.grep(/Sun/i).empty?
        Net::DHCP::Record.new attrs
      else
        Net::DHCP::SparcRecord.new attrs
      end
    rescue RestClient::ResourceNotFound
      nil
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to retrieve DHCP entry for %s"), mac)
    end

    # Retrieves an array of DHCP entries
    # [+subnet+] : String in dotted decimal format
    # [+ip+]    : ip address
    # Returns    : Hash or false
    def records_by_ip(subnet, ip)
      response = parse(get("#{subnet}/ip/#{ip}"))
      response.map do |entry|
        attrs = entry.merge(:network => subnet, :proxy => self)
        if entry.keys.grep(/Sun/i).empty?
          Net::DHCP::Record.new attrs
        else
          Net::DHCP::SparcRecord.new attrs
        end
      end
    rescue RestClient::ResourceNotFound
      nil
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to retrieve DHCP entry for %s"), ip)
    end

    # Sets a DHCP entry
    # [+subnet+] : String in dotted decimal format
    # [+mac+]    : String in coloned sextuplet format
    # [+args+]   : Hash containing DHCP values. The :mac key is taken from the mac parameter
    # Returns    : Boolean status
    def set(subnet, args)
      raise "Must define a subnet" if subnet.empty?
      raise "Must provide arguments" unless args.is_a?(Hash)
      parse(post(args, subnet.to_s))
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to set DHCP entry"))
    end

    # Deletes a DHCP entry
    # [+subnet+] : String in dotted decimal format
    # [+mac+]    : String in coloned sextuplet format
    # Returns    : Boolean status
    def delete(subnet, mac)
      parse super("#{subnet}/mac/#{mac}")
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to delete DHCP entry for %s"), mac)
    end
  end
end
