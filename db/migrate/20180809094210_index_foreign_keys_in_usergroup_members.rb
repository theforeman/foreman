class IndexForeignKeysInUsergroupMembers < ActiveRecord::Migration[5.1]
  def change
    add_index :usergroup_members, :member_id
    add_index :usergroup_members, :usergroup_id
  end
end
