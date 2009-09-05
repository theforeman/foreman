class HostParametersController < ApplicationController
  active_scaffold :host_parameters do |config|
    config.columns = [ :name, :value ]
  end
end
