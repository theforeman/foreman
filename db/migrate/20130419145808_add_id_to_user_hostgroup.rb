class AddIdToUserHostgroup < ActiveRecord::Migration
  def self.up
    add_column :user_hostgroups, :id, :primary_key
  end

  def self.down
    remove_column :user_hostgroups, :id
  end
end
