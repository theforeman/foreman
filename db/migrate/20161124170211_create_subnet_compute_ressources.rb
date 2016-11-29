class CreateSubnetComputeRessources < ActiveRecord::Migration
  def up
    create_table :subnet_compute_resources do |t|
      t.references :compute_resource
      t.references :subnet

      t.timestamps
    end
  end

  def down
    drop_table :subnet_compute_resources
  end
end
