class AddLocationsOrganizations < ActiveRecord::Migration
  def self.up
    create_table :locations_organizations, :id => false do |t|
      t.integer :location_id
      t.integer :organization_id

      t.timestamps
    end
  end

  def self.down
    drop_table :locations_organizations
  end
end
