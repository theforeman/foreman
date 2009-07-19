class FactValuesController < ApplicationController
  active_scaffold :fact_value do |config|
    config.list.columns = [:fact_name, :value]
    config.actions = [:list]
    config.columns[:fact_name].clear_link
  end

end
