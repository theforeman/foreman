class SetPtableLayoutToText < ActiveRecord::Migration[4.2]
  def up
    change_column :ptables, :layout, :text, :null => false
  end

  def down
    change_column :ptables, :layout, :string, :limit => 4096, :null => false
  end
end
