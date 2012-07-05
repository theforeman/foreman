class AddAttributesToComputeResources < ActiveRecord::Migration
  def self.up
    add_column :compute_resources, :attrs, :text
  end

  def self.down
    remove_column :compute_resources, :attrs
  end
end
