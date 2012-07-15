class AddAttributesToComputeResources < ActiveRecord::Migration
  def self.up
    add_column :compute_resources, :attrs, :text unless column_exists? :compute_resources, :attrs
  end

  def self.down
    remove_column :compute_resources, :attrs if column_exists? :compute_resources, :attrs
  end
end
