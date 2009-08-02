class EnvironmentsController < ApplicationController
  active_scaffold :environment do |config|
    config.columns = %w{name}
  end
end
