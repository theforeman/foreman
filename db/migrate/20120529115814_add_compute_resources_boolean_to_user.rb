class AddComputeResourcesBooleanToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :compute_resources_andor, :string, :limit => 3, :default => "or"
  end

  def self.down
    remove_column :users, :compute_resources_andor
  end
end
