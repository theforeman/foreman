class AddLabelToHostGroup < ActiveRecord::Migration[4.2]
  def up
    add_column :hostgroups, :label, :string, :limit => 255
  end

  def down
    remove_column :hostgroups, :label
  end
end
