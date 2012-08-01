class CreateOrganizationHosts < ActiveRecord::Migration
  def self.up
    create_table :organization_hosts do |t|
      t.integer :organization_id
      t.integer :host_id

      t.timestamps
    end
  end

  def self.down
    drop_table :organization_hosts
  end
end
