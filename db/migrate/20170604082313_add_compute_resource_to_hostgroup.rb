class AddComputeResourceToHostgroup < ActiveRecord::Migration[4.2]
  def up
    add_column :hostgroups, :compute_resource_id, :integer
    add_foreign_key :hostgroups, :compute_resources
  end

  def down
    remove_column :hostgroups, :compute_resource_id
  end
end
