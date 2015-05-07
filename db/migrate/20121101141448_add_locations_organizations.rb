class AddLocationsOrganizations < ActiveRecord::Migration
  def up
    create_table :locations_organizations, :id => false do |t|
      t.integer :location_id
      t.integer :organization_id
    end
  end

  def down
    drop_table :locations_organizations
  end
end
