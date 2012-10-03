class AddTaxonomyIdsToHosts < ActiveRecord::Migration
  def self.up
    add_column :hosts, :organization_id, :integer
    add_column :hosts, :location_id, :integer
    add_column :taxonomies, :host_id, :integer
  end

  def self.down
    remove_column :hosts, :organization_id
    remove_column :hosts, :location_id
  end
end
