class UpdateParamsPriority < ActiveRecord::Migration
  def up
    Parameter.unscoped.where("type = 'OsParameter'").update_all(:priority => 3)
    Parameter.unscoped.where("type = 'GroupParameter'").update_all(:priority => 4)
    Parameter.unscoped.where("type = 'HostParameter'").update_all(:priority => 5)
  end
  def down
    Parameter.unscoped.where("type = 'OsParameter'").update_all(:priority => 2)
    Parameter.unscoped.where("type = 'GroupParameter'").update_all(:priority => 3)
    Parameter.unscoped.where("type = 'HostParameter'").update_all(:priority => 4)
  end
end
