module ProxyAPI
  class TFTP < Resource
    def initialize args
      @url     = args[:url] + "/tftp"
      @variant = args[:variant]
      super args
    end

    # Creates a TFTP boot entry
    # [+mac+]  : MAC address
    # [+args+] : Hash containing
    #    :pxeconfig => String containing the configuration
    # Returns  : Boolean status
    def set mac, args
      parse(post(args, "#{@variant}/#{mac}"))
    end

    # Deletes a TFTP boot entry
    # [+mac+] : String in coloned sextuplet format
    # Returns : Boolean status
    def delete mac
      parse(super("#{@variant}/#{mac}"))
    end

    # Requests that the proxy download the bootfile from the media's source
    # [+args+] : Hash containing
    #   :prefix => String containing the location within the TFTP tree to store the file
    #   :path   => String containing the URL of the file to download
    # Returns    : Boolean status
    def fetch_boot_file args
      parse(post(args, "fetch_boot_file"))
    end

    # returns the TFTP boot server for this proxy
    def bootServer
      if (response = parse(get("serverName"))) and response["serverName"].present?
        return response["serverName"]
      end
      false
    rescue RestClient::ResourceNotFound
      nil
    end

    # Create a default pxe menu
    # [+args+] : Hash containing
    #   :menu => String containing the menu text
    # Returns    : Boolean status
    def create_default args
      parse(post(args, "create_default"))
    end

  end
end

