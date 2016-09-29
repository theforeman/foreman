class AddTaxonomyIdsToHosts < ActiveRecord::Migration
  def up
    add_column :hosts, :organization_id, :integer
    add_column :hosts, :location_id, :integer
  end

  def down
    remove_column :hosts, :organization_id
    remove_column :hosts, :location_id
  end
end
