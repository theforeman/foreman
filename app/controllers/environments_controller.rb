class EnvironmentsController < ApplicationController
  active_scaffold :environments do |config|
    config.columns = %w{name hosttypes}
    config.columns[:hosttypes].form_ui  = :select
  end
end
