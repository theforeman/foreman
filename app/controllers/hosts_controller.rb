class HostsController < ApplicationController
  active_scaffold  :hosts do |config|
    config.columns[:architecture].form_ui  = :select
    config.columns[:media].form_ui  = :select
    config.columns[:domain].form_ui  = :select
    config.columns[:subnet].form_ui  = :select
    config.columns[:os].form_ui  = :select
    columns[:architecture].label = "Arch"
  end
end
