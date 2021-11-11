class UpdateOsMinor < ActiveRecord::Migration[4.2]
  def up
    change_column :operatingsystems, :minor, :string, :limit => 16, :default => "", :null => false
  end

  def down
    change_column :operatingsystems, :minor, :string, :limit => 16
  end
end
