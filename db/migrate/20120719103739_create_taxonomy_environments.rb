class CreateTaxonomyEnvironments < ActiveRecord::Migration
  def self.up
    create_table :taxonomy_environments, :id => false do |t|
      t.integer :taxonomy_id
      t.integer :environment_id

      t.timestamps
    end
  end

  def self.down
    drop_table :taxonomy_environments
  end
end
