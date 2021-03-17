class AddDisksTotalToHostFacets < ActiveRecord::Migration[6.0]
  def up
    add_column :host_facets_reported_data_facets, :disks_total, :bigint
  end

  def down
    remove_column :host_facets_reported_data_facets, :disks_total
  end
end
