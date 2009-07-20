class DomainController < ApplicationController
  active_scaffold :domain do |config|
    config.columns = [:fullname, :dnsserver, :gateway]
    config.create.columns = [:name, :fullname, :dnsserver, :gateway]
  end

end
