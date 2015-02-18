module ProxyAPI
  class TFTP < ProxyAPI::Resource
    def initialize(args)
      @url     = args[:url] + "/tftp"
      @variant = args[:variant]
      super args
    end

    # Creates a TFTP boot entry
    # [+mac+]  : MAC address
    # [+args+] : Hash containing
    #    :pxeconfig => String containing the configuration
    # Returns  : Boolean status
    def set(mac, args)
      parse(post(args, "#{@variant}/#{mac}"))
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to set TFTP boot entry for %s"), mac)
    end

    # Deletes a TFTP boot entry
    # [+mac+] : String in coloned sextuplet format
    # Returns : Boolean status
    def delete(mac)
      parse(super("#{@variant}/#{mac}"))
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to delete TFTP boot entry for %s"), mac)
    end

    # Requests that the proxy download the bootfile from the media's source
    # [+args+] : Hash containing
    #   :prefix => String containing the location within the TFTP tree to store the file
    #   :path   => String containing the URL of the file to download
    # Returns    : Boolean status
    def fetch_boot_file(args)
      parse(post(args, "fetch_boot_file"))
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to fetch TFTP boot file"))
    end

    # returns the TFTP boot server for this proxy
    def bootServer
      if (response = parse(get("serverName"))) and response["serverName"].present?
        return response["serverName"]
      end
      false
    rescue RestClient::ResourceNotFound
      nil
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to detect TFTP boot server"))
    end

    # Create a default pxe menu
    # [+args+] : Hash containing
    #   :menu => String containing the menu text
    # Returns    : Boolean status
    def create_default(args)
      parse(post(args, "create_default"))
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to create default TFTP boot menu"))
    end
  end
end

