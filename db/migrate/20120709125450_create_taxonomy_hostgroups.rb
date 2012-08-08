class CreateTaxonomyHostgroups < ActiveRecord::Migration
  def self.up
    create_table :taxonomy_hostgroups do |t|
      t.integer :taxonomy_id
      t.integer :hostgroup_id

      t.timestamps
    end
  end

  def self.down
    drop_table :taxonomy_hostgroups
  end
end
