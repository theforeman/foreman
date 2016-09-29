class CreateCachedUsergroupMembers < ActiveRecord::Migration
  def change
    create_table :cached_usergroup_members do |t|
      t.integer :user_id
      t.integer :usergroup_id

      t.timestamps
    end

    add_index :cached_usergroup_members, :user_id
    add_index :cached_usergroup_members, :usergroup_id

    UsergroupMember.all.each(&:save!)
  end
end
