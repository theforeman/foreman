require 'cleanup_helper'

class CleanTrendsAndForemanDockerData < ActiveRecord::Migration[6.1]
  def up
    ::CleanupHelper.clean_foreman_docker
    ::CleanupHelper.clean_trends
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
