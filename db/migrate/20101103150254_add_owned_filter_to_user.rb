class AddOwnedFilterToUser < ActiveRecord::Migration
  def up
    add_column :users, :filter_on_owner, :boolean
  end

  def down
    remove_column :users, :filter_on_owner
  end
end
