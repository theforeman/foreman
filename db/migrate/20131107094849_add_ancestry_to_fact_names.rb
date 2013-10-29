class AddAncestryToFactNames < ActiveRecord::Migration
  def self.up
    add_column :fact_names, :ancestry, :string
    add_index :fact_names, :ancestry
  end

  def self.down
    remove_index :fact_names, :ancestry
    remove_column :fact_names, :ancestry, :string
  end
end
