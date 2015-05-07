class AddUuidAndComputeIdToHost < ActiveRecord::Migration
  def up
    add_column :hosts, :uuid, :string
    add_column :hosts, :compute_resource_id, :integer
  end

  def down
    remove_column :hosts, :uuid
    remove_column :hosts, :compute_resource
  end
end
