class ArchitectureController < ApplicationController
  active_scaffold :architecture do |config|
    config.columns = %w{ name }
  end
end
