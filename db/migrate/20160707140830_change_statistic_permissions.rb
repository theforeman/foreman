class ChangeStatisticPermissions < ActiveRecord::Migration
  def up
    Permission.find_by_name('view_statistics').update_attributes({"resource_type"=>"Statistic"})
  end

  def down
    Permission.find_by_name('view_statistics').update_attributes({"resource_type"=>nil})
  end
end
