class DomainsController < ApplicationController
  helper :domain
  active_scaffold :domain do |config|
    config.columns = [:fullname, :dnsserver, :gateway]
    config.create.columns = [:name, :fullname, :dnsserver, :gateway]
    config.columns[:fullname].description = "Locations full name, available as a variable"
    config.nested.add_link("Hosts", [:hosts])
  end

end
