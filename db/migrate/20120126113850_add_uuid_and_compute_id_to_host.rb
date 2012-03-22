class AddUuidAndComputeIdToHost < ActiveRecord::Migration
  def self.up
    add_column :hosts, :uuid, :string
    add_column :hosts, :compute_resource_id, :integer
  end

  def self.down
    remove_column :hosts, :uuid
    remove_column :hosts, :compute_resource
  end
end
