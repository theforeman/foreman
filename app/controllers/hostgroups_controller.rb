class HostgroupsController < ApplicationController
  active_scaffold :hostgroups do |config|
    config.columns = [ :name, :puppetclasses, :group_parameters]
    config.columns[:name].description = "The name of the group"
    config.columns[:puppetclasses].form_ui  = :select
  end

end
