class AddBiosToHostFacets < ActiveRecord::Migration[6.1]
  def up
    add_column :host_facets_reported_data_facets, :bios_vendor, :string, :limit => 255
    add_column :host_facets_reported_data_facets, :bios_release_date, :string, :limit => 255
    add_column :host_facets_reported_data_facets, :bios_version, :string, :limit => 255
  end

  def down
    remove_column :host_facets_reported_data_facets, :bios_vendor
    remove_column :host_facets_reported_data_facets, :bios_release_date
    remove_column :host_facets_reported_data_facets, :bios_version
  end
end
