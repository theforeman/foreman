class AddEnabledToHosts < ActiveRecord::Migration
  def up
    add_column :hosts, :enabled, :boolean, :default => true
  end

  def down
    remove_column :hosts, :enabled
  end
end
