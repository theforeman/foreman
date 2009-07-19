class HostsController < ApplicationController
  active_scaffold  :hosts do |config|
    config.list.columns = [:name, :os, :architecture, :last_compile ]
    config.columns[:architecture].form_ui  = :select
    config.columns[:media].form_ui  = :select
    config.columns[:domain].form_ui  = :select
    config.columns[:subnet].form_ui  = :select
    config.columns[:os].form_ui  = :select
    columns[:architecture].label = "Arch"
    config.columns[:fact_values].association.reverse = :host
    config.nested.add_link("Host Info", [:fact_values])
  end
end
