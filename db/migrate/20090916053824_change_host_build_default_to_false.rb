class ChangeHostBuildDefaultToFalse < ActiveRecord::Migration[4.2]
  def up
    change_column :hosts, :build, :boolean, :default => false
  end

  def down
    change_column :hosts, :build, :boolean, :default => true
  end
end
