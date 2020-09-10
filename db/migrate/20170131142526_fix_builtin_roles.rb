class FixBuiltinRoles < ActiveRecord::Migration[4.2]
  def up
    Role.where(:builtin => nil).update_all(:builtin => 0)
  end
end
