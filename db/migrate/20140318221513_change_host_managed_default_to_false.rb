class ChangeHostManagedDefaultToFalse < ActiveRecord::Migration
  def self.up
    Host.unscoped.where(:managed => nil).update_all(:managed => false)
    change_column :hosts, :managed, :boolean, :null => false, :default => false
  end

  def self.down
    change_column :hosts, :managed, :boolean, :null => true
  end
end

