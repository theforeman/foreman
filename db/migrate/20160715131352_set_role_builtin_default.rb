class SetRoleBuiltinDefault < ActiveRecord::Migration[4.2]
  def up
    change_column_default :roles, :builtin, 0
  end

  def down
    change_column_default :roles, :builtin, nil
  end
end
