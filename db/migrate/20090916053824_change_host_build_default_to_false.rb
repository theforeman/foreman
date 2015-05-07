class ChangeHostBuildDefaultToFalse < ActiveRecord::Migration
  def up
    change_column :hosts, :build, :boolean, :default => false

    Host.unscoped.find_each {|h| h.update_attribute :build, false}
  end

  def down
    change_column :hosts, :build, :boolean, :default => true
  end
end
