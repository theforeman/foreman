class CreateTaxonomySubnets < ActiveRecord::Migration
  def self.up
    create_table :taxonomy_subnets, :id => false do |t|
      t.integer :taxonomy_id
      t.integer :subnet_id

      t.timestamps
    end
  end

  def self.down
    drop_table :taxonomy_subnets
  end
end
