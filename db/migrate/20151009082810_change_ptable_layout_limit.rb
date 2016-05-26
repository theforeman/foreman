class ChangePtableLayoutLimit < ActiveRecord::Migration
  def up
    change_column :ptables, :layout, :string, :limit => 20000, :null => false
  end

  def down
    change_column :ptables, :layout, :string, :limit => 4096, :null => false
  end
end
