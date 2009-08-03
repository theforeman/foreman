# a generic module for dhcp queries and commands
# a seperate class should be created for each type of dhcp class
module DHCP
  # There has been a problem with the gateway transport or the data
  # we received does not make sense
  class DHCPError < RuntimeError
  end

  # This class models the DHCP subnets within the organisation
  # After initialisation individual subnets can be referenced by
  # dhcp = DHCP::Server.new([subnet1, subnet2, ...], :user => xxx, :password => xxx)
  # mac = dhcp["172.29.216.0"]["172.29.216.33"]

  class Server < Hash
    def initialize(scopes)
      # get scope data
      # this includes ip, mac address etc
      scopes.each do |scope|
        self[scope] = nil
        loadScopeData Subnet.find_by_number(scope).map {|s| s.number, s.dhcpServer}
      end
    end

    # delete the reservation for a host
    # where host is a host model 
    def delReservation(host)
    end

    # creates the reservation for this host
    # where host is a host model
    def setReservationFor(host)
    end


    private

    # get a list of all scopes the dhcp server supports
    def loadScopes

    end

    # loads all scope reservations into cache
    def loadScopeData server, scopeIpAddress 
      RAILS_DEFAULT_LOGGER.debug "Loading scope: " + scopeIpAddress
    end

    # returnis reservation details
    def getDetails ip
      RAILS_DEFAULT_LOGGER.debug "Loading DHCP settings for IP: " + ip
    end

    # flush our cache for this server
    # memcache should be the default cacher
    def flush 
    end

    def delRecordFor(scopeIpAddress, ip)
    end

    def setRecordFor(scopeIpAddress, ip, hostname, mac, bootServer=nil, bootFile=nil, model=nil)
    end

  end
end
