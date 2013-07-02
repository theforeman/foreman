module ProxyAPI
  class DNS < ProxyAPI::Resource
    def initialize args
      @url  = args[:url] + "/dns"
      super args
    end

    # Sets a DNS entry
    # [+fqdn+] : String containing the FQDN of the host
    # [+args+] : Hash containing :value and :type: The :fqdn key is taken from the fqdn parameter
    # Returns  : Boolean status
    def set args
      parse post(args, "")
    end

    # Deletes a DNS entry
    # [+key+] : String containing either a FQDN or a dotted quad plus .in-addr.arpa.
    # Returns    : Boolean status
    def delete key
      parse(super("#{key}"))
    rescue RestClient::ResourceNotFound
      # entry doesn't exists anyway
      return true
    end
  end
end
