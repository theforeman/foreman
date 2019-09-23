class AddFieldsToReportedDataFacet < ActiveRecord::Migration[5.2]
  def up
    add_column :host_facets_reported_data_facets, :virtual, :boolean
    add_column :host_facets_reported_data_facets, :sockets, :integer
    add_column :host_facets_reported_data_facets, :cores, :integer
    add_column :host_facets_reported_data_facets, :ram, :integer
  end

  def down
    remove_column :host_facets_reported_data_facets, :virtual
    remove_column :host_facets_reported_data_facets, :sockets
    remove_column :host_facets_reported_data_facets, :cores
    remove_column :host_facets_reported_data_facets, :ram
  end
end
