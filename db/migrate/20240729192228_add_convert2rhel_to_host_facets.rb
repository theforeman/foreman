class AddConvert2rhelToHostFacets < ActiveRecord::Migration[6.1]
  def up
    add_column :host_facets_reported_data_facets, :convert2rhel, :int4
  end

  def down
    remove_column :host_facets_reported_data_facets, :convert2rhel
  end
end
