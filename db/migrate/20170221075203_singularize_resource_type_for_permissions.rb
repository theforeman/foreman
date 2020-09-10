class SingularizeResourceTypeForPermissions < ActiveRecord::Migration[4.2]
  def up
    Permission.where(:resource_type => "ExternalUsergroups").map do |perm|
      perm.resource_type = "ExternalUsergroup"
      perm.save!
    end
  end

  def down
    Permission.where(:resource_type => "ExternalUsergroup").map do |perm|
      perm.resource_type = "ExternalUsergroups"
      perm.save!
    end
  end
end
