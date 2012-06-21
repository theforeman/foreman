class CreateOrganizationDomains < ActiveRecord::Migration
  def self.up
    create_table :organization_domains do |t|
      t.integer :organization_id
      t.integer :domain_id

      t.timestamps
    end
  end

  def self.down
    drop_table :organization_domains
  end
end
