class CommonParametersController < ApplicationController
  active_scaffold :common_parameter do |config|
    config.columns = [ :name, :value ]
  end
end
