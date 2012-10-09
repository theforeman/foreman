class CreateTaxonomyPuppetclasses < ActiveRecord::Migration
  def self.up
    create_table :taxonomy_puppetclasses, :id => false do |t|
      t.integer :taxonomy_id
      t.integer :puppetclass_id
    end
  end

  def self.down
    drop_table :taxonomy_puppetclasses
  end
end
