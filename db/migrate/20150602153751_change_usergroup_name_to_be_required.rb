class ChangeUsergroupNameToBeRequired < ActiveRecord::Migration[4.2]
  def up
    change_column :usergroups, :name, :string, :null => false
  end

  def down
    change_column :usergroups, :name, :string, :null => true
  end
end
