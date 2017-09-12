class ChangeAuthSourceResourceType < ActiveRecord::Migration
  def up
    Permission.where(:resource_type => 'AuthSourceLdap').update_all(:resource_type => 'AuthSource')
  end

  def down
    Permission.where(:resource_type => 'AuthSource').update_all(:resource_type => 'AuthSourceLdap')
  end
end
