class AddIdToUserHostgroup < ActiveRecord::Migration[4.2]
  def up
    add_column :user_hostgroups, :id, :primary_key
  end

  def down
    remove_column :user_hostgroups, :id
  end
end
