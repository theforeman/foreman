class ParametersController < ApplicationController
  active_scaffold :parameters do |config|
    config.columns[:name].description = "puppet special varabile for this host (External Nodes)"
  end
end
