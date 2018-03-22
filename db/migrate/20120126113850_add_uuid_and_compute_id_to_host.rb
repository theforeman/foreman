class AddUuidAndComputeIdToHost < ActiveRecord::Migration[4.2]
  def up
    add_column :hosts, :uuid, :string, :limit => 255
    add_column :hosts, :compute_resource_id, :integer
  end

  def down
    remove_column :hosts, :uuid
    remove_column :hosts, :compute_resource
  end
end
