module ProxyAPI
  class Wol < ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + "/wol"
      super args
    end

    # Send Wake on LAN request
    # [+mac+] : MAC address in coloned sextuplet format
    # Returns : Boolean status
    def wake(mac)
      raise "Must define a MAC address" if mac.blank?

      params = { :mac_address => mac }
      parse post(params)
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to send Wake on LAN request for MAC %s"), mac)
    end
  end
end
