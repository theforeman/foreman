module ProxyAPI
  class DHCP < Resource
    def initialize args
      @url  = args[:url] + "/dhcp"
      super args
    end

    # Retrieve the Server's subnets
    # Returns: Array of Hashes or false
    # Example [{"network":"192.168.11.0","netmask":"255.255.255.0"},{"network":"192.168.122.0","netmask":"255.255.255.0"}]
    def subnets
      parse get
    end

    def subnet subnet
      parse get(subnet)
    end

    def unused_ip subnet, mac = nil
      params = {}
      params.merge!({:mac => mac}) if mac.present?

      params.merge!({:from => subnet.from, :to => subnet.to}) if subnet.from.present? and subnet.to.present?
      if params.any?
        params = "?" + params.map{|e| e.join("=")}.join("&")
      else
        params = ""
      end
      parse get("#{subnet.network}/unused_ip#{params}")
    end

    # Retrieves a DHCP entry
    # [+subnet+] : String in dotted decimal format
    # [+mac+]    : String in coloned sextuplet format
    # Returns    : Hash or false
    def record subnet, mac
      response = parse(get("#{subnet}/#{mac}"))
      attrs = response.merge(:network => subnet, :proxy => self)
      if response.keys.grep(/Sun/i).empty?
        Net::DHCP::Record.new attrs
      else
        Net::DHCP::SparcRecord.new attrs
      end
    rescue RestClient::ResourceNotFound
      nil
    end

    # Sets a DHCP entry
    # [+subnet+] : String in dotted decimal format
    # [+mac+]    : String in coloned sextuplet format
    # [+args+]   : Hash containing DHCP values. The :mac key is taken from the mac parameter
    # Returns    : Boolean status
    def set subnet, args
      raise "Must define a subnet" if subnet.empty?
      raise "Must provide arguments" unless args.is_a?(Hash)
      parse(post(args, subnet.to_s))
    end

    # Deletes a DHCP entry
    # [+subnet+] : String in dotted decimal format
    # [+mac+]    : String in coloned sextuplet format
    # Returns    : Boolean status
    def delete subnet, mac
      parse super("#{subnet}/#{mac}")
    rescue RestClient::ResourceNotFound
      # entry doesn't exists anyway
      return true
    end
  end
end
