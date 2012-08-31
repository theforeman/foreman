class CreateTaxonomySubnets < ActiveRecord::Migration
  def self.up
    create_table :taxonomy_subnets do |t|
      t.integer :taxononomy_id
      t.integer :subnet_id

      t.timestamps
    end
  end

  def self.down
    drop_table :taxonomy_subnets
  end
end
