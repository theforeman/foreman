class DomainParametersController < ApplicationController
  active_scaffold :domain_parameters do |config|
    config.columns = [ :name, :value ]
  end
end
