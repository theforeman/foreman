class PtablesController < ApplicationController
  active_scaffold :ptable do |config|
    config.label = "Partition tables"
    config.list.columns = [:name ]
    config.columns = %w{ name layout }
    config.columns[:layout].description = "The partition layout you would like to use"
    config.nested.add_link("Hosts", [:hosts])
    config.nested.add_link("Operating systems", [:operatingsystems])
  end
end
