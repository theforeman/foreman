class AddKernelVersionToHostFacets < ActiveRecord::Migration[6.1]
  def up
    add_column :host_facets_reported_data_facets, :kernel_version, :string, :limit => 255
  end

  def down
    remove_column :host_facets_reported_data_facets, :kernel_version
  end
end
