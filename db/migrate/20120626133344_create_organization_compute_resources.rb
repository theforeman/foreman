class CreateOrganizationComputeResources < ActiveRecord::Migration
  def self.up
    create_table :organization_compute_resources do |t|
      t.integer :organization_id
      t.integer :compute_resource_id

      t.timestamps
    end
  end

  def self.down
    drop_table :organization_compute_resources
  end
end
