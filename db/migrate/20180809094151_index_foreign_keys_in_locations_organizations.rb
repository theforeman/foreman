class IndexForeignKeysInLocationsOrganizations < ActiveRecord::Migration[5.1]
  def change
    add_index :locations_organizations, :location_id
    add_index :locations_organizations, :organization_id
  end
end
