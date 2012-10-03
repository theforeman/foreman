class AddBmcFeatureToProxy < ActiveRecord::Migration
  def self.up
    Feature.find_or_create_by_name("BMC")
  end

  def self.down
  end
end
