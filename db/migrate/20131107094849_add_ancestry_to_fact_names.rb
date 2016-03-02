class AddAncestryToFactNames < ActiveRecord::Migration
  def up
    add_column :fact_names, :ancestry, :string, :limit => 255
    add_index :fact_names, :ancestry
  end

  def down
    remove_index :fact_names, :ancestry
    remove_column :fact_names, :ancestry, :string
  end
end
