class AddAncestryToHostgroup < ActiveRecord::Migration[4.2]
  def up
    add_column :hostgroups, :ancestry, :string, :limit => 255
    add_index :hostgroups, :ancestry
  end

  def down
    remove_index :hostgroups, :ancestry
    remove_column :hostgroups, :ancestry
  end
end
