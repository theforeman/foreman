class RemoveChefProxy < ActiveRecord::Migration
  def up
    chef_feature = Feature.find_by_name("Chef Proxy")
    chef_feature.destroy if chef_feature
  end

  def down
    Feature.where(:name => "Chef Proxy").first_or_create!
  end
end
