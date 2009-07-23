class HosttypesController < ApplicationController
  active_scaffold :hosttypes do |config|
    config.columns = [ :name, :operatingsystems, :nameindicator, :environments ]
    config.columns[:operatingsystems].form_ui  = :select
    config.columns[:environments].form_ui  = :select
  end
end
