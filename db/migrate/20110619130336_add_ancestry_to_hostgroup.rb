class AddAncestryToHostgroup < ActiveRecord::Migration
  def up
    add_column :hostgroups, :ancestry, :string
    add_index :hostgroups, :ancestry
  end

  def down
    remove_index :hostgroups, :ancestry
    remove_column :hostgroups, :ancestry
  end
end
