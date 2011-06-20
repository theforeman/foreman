class AddAncestryToHostgroup < ActiveRecord::Migration
  def self.up
    add_column :hostgroups, :ancestry, :string
    add_index :hostgroups, :ancestry
  end

  def self.down
    remove_index :hostgroups, :ancestry
    remove_column :hostgroups, :ancestry
  end
end
