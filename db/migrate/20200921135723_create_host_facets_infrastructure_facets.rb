class CreateHostFacetsInfrastructureFacets < ActiveRecord::Migration[6.0]
  def change
    create_table :host_facets_infrastructure_facets do |t|
      t.references :host, type: :integer, foreign_key: true, index: { unique: true }
      t.boolean :foreman_instance, default: false, null: false

      t.references :smart_proxy
    end
  end
end
