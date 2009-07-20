class OperatingsystemController < ApplicationController
  active_scaffold :operatingsystem do |config|
    config.columns = [:name, :major]
  end
end
