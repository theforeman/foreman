class FixBuiltinRoles < ActiveRecord::Migration
  def up
    Role.where(:builtin => nil).update_all(:builtin => 0)
  end
end
