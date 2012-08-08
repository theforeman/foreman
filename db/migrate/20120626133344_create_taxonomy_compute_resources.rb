class CreateTaxonomyComputeResources < ActiveRecord::Migration
  def self.up
    create_table :taxonomy_compute_resources do |t|
      t.integer :taxonomy_id
      t.integer :compute_resource_id

      t.timestamps
    end
  end

  def self.down
    drop_table :taxonomy_compute_resources
  end
end
