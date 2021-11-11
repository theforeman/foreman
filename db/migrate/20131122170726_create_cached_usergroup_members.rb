class CreateCachedUsergroupMembers < ActiveRecord::Migration[4.2]
  def change
    create_table :cached_usergroup_members do |t|
      t.integer :user_id
      t.integer :usergroup_id

      t.timestamps null: true
    end

    add_index :cached_usergroup_members, :user_id
    add_index :cached_usergroup_members, :usergroup_id
  end
end
