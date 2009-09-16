class ChangeHostBuildDefaultToFalse < ActiveRecord::Migration
  def self.up
      change_column :hosts, :build, :boolean, :default => false

      Host.find_each {|h| h.update_attribute :build, false}
  end

  def self.down
      change_column :hosts, :build, :boolean, :default => true
  end
end
