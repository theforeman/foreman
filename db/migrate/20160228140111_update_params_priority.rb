class UpdateParamsPriority < ActiveRecord::Migration[4.2]
  def up
    OsParameter.unscoped.update_all(:priority => 3)
    GroupParameter.unscoped.update_all(:priority => 4)
    HostParameter.unscoped.update_all(:priority => 5)
  end

  def down
    OsParameter.unscoped.update_all(:priority => 2)
    GroupParameter.unscoped.update_all(:priority => 3)
    HostParameter.unscoped.update_all(:priority => 4)
  end
end
