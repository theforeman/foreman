class GroupParametersController < ApplicationController
  active_scaffold :group_parameters do |config|
    config.columns = [ :name, :value ]
  end
end
