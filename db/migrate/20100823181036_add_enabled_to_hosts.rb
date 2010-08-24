class AddEnabledToHosts < ActiveRecord::Migration
  def self.up
    add_column :hosts, :enabled, :boolean, :default => 1
  end

  def self.down
    remove_column :hosts, :enabled
  end
end
