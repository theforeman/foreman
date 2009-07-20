class HostsController < ApplicationController
  active_scaffold  :host do |config|
    config.list.columns = [:name, :operatingsystem, :architecture, :last_compile ]
    config.columns = %w{ name ip architecture media domain operatingsystem mac root_pass serial puppetmaster disk comment}
    config.columns[:architecture].form_ui  = :select
    config.columns[:media].form_ui  = :select
    config.columns[:domain].form_ui  = :select
    config.columns[:subnet].form_ui  = :select
    config.columns[:operatingsystem].form_ui  = :select
    columns[:architecture].label = "Arch"
  end
end
