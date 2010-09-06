class AddOwnedFilterToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :filter_on_owner, :boolean
  end

  def self.down
    remove_column :users, :filter_on_owner
  end
end
