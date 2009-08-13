class ArchitecturesController < ApplicationController
  active_scaffold :architecture do |config|
    config.columns = %w{ name }
    config.nested.add_link("Hosts", [:hosts])
    config.nested.add_link("Operating systems", [:operatingsystem])
  end
end
