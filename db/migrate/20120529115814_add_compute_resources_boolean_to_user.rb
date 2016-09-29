class AddComputeResourcesBooleanToUser < ActiveRecord::Migration
  def up
    add_column :users, :compute_resources_andor, :string, :limit => 3, :default => "or"
  end

  def down
    remove_column :users, :compute_resources_andor
  end
end
