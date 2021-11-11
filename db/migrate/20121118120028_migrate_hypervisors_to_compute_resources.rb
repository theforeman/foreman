class MigrateHypervisorsToComputeResources < ActiveRecord::Migration[4.2]
  def up
    drop_table :hypervisors, if_exists: true
  end

  def down
  end
end
