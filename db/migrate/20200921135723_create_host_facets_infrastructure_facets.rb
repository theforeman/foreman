class CreateHostFacetsInfrastructureFacets < ActiveRecord::Migration[6.0]
  def change
    create_table :host_facets_infrastructure_facets do |t|
      t.references :host, type: :integer, foreign_key: true, index: { unique: true }
      t.string :foreman_uuid

      t.references :smart_proxy
      t.string :smart_proxy_uuid
    end
  end
end
