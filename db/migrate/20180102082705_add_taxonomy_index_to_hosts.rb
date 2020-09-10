class AddTaxonomyIndexToHosts < ActiveRecord::Migration[5.1]
  def change
    add_index :hosts, [:type, :organization_id, :location_id]
    add_index :hosts, [:type, :location_id]
  end
end
