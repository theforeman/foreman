class SetRoleBuiltinDefault < ActiveRecord::Migration
  def up
    change_column_default :roles, :builtin, 0
  end

  def down
    change_column_default :roles, :builtin, nil
  end
end
