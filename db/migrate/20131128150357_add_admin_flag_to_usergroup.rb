class AddAdminFlagToUsergroup < ActiveRecord::Migration[4.2]
  def change
    add_column :usergroups, :admin, :boolean, :null => false, :default => false
  end
end
