class AddAdminFlagToUsergroup < ActiveRecord::Migration
  def change
    add_column :usergroups, :admin, :boolean, :null => false, :default => false
  end
end
