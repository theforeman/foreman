class AddIndexToSshKeys < ActiveRecord::Migration
  def change
    add_index :ssh_keys, :user_id
  end
end
