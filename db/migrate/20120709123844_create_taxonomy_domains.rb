class CreateTaxonomyDomains < ActiveRecord::Migration
  def self.up
    create_table :taxonomy_domains, :id => false do |t|
      t.integer :taxonomy_id
      t.integer :domain_id

      t.timestamps
    end
  end

  def self.down
    drop_table :taxonomy_domains
  end
end
