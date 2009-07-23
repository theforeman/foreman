class ModelController < ApplicationController
  active_scaffold :models do |config|
    config.columns = [ :name, :info, :hosts ]
    config.columns[:hosts].form_ui  = :select
  end

end
