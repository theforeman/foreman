class CommonParametersController < ApplicationController
  active_scaffold :common_parameters do |config|
    config.columns = [ :name, :value ]
  end
end
