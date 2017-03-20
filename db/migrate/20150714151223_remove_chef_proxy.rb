class RemoveChefProxy < ActiveRecord::Migration
  def up
    Feature.where("name = 'Chef Proxy'").delete_all
  end

  def down
    Feature.where(:name => "Chef Proxy").first_or_create!
  end
end
