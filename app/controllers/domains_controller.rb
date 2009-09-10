class DomainsController < ApplicationController
  helper :domain
  active_scaffold :domain do |config|
    config.list.columns = [:fullname]
    config.columns = [:name, :fullname, :domain_parameters]
    config.columns[:fullname].description = "Locations full name, available as a variable"
    config.nested.add_link("Hosts", [:hosts])
  end

end
