class CreateTaxonomyHosts < ActiveRecord::Migration
  def self.up
    create_table :taxonomy_hosts do |t|
      t.integer :taxonomy_id
      t.integer :host_id

      t.timestamps
    end
  end

  def self.down
    drop_table :taxonomy_hosts
  end
end
