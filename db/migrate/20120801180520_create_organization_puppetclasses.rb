class CreateOrganizationPuppetclasses < ActiveRecord::Migration
  def self.up
    create_table :organization_puppetclasses do |t|
      t.integer :organization_id
      t.integer :puppetclass_id
    end
  end

  def self.down
    drop_table :organization_puppetclasses
  end
end
