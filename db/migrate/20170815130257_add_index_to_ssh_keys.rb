class AddIndexToSshKeys < ActiveRecord::Migration[4.2]
  def change
    add_index :ssh_keys, :user_id
  end
end
