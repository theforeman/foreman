class CreateHostFacetsReportedDataFacets < ActiveRecord::Migration[5.2]
  def change
    create_table :host_facets_reported_data_facets do |t|
      t.references :host, type: :integer, foreign_key: true, index: { unique: true }
      t.datetime :boot_time

      t.timestamps
    end
  end
end
