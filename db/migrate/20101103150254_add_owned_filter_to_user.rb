class AddOwnedFilterToUser < ActiveRecord::Migration[4.2]
  def up
    add_column :users, :filter_on_owner, :boolean
  end

  def down
    remove_column :users, :filter_on_owner
  end
end
