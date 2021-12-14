module ProxyAPI
  class DNS < ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + "/dns"
      super args
    end

    # Sets a DNS entry
    # [+fqdn+] : String containing the FQDN of the host
    # [+args+] : Hash containing :value and :type: The :fqdn key is taken from the fqdn parameter
    # Returns  : Boolean status
    def set(args)
      parse post(args, "")
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to set DNS entry"))
    end

    # Deletes a DNS entry
    # [+key+] : String containing either a FQDN or a dotted quad plus .in-addr.arpa.
    # Returns    : Boolean status
    def delete(key)
      parse(super(key.to_s))
    rescue RestClient::ResourceNotFound
      # entry doesn't exists anyway
      true
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to delete DNS entry"))
    end
  end
end
