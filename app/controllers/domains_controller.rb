class DomainsController < ApplicationController
  active_scaffold :domain do |config|
    config.columns = [:fullname, :dnsserver, :gateway]
    config.create.columns = [:name, :fullname, :dnsserver, :gateway]
    config.columns[:fullname].description = "Locations full name, available as a variable"
  end

end
