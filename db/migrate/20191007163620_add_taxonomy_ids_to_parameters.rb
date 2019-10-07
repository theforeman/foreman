class AddTaxonomyIdsToParameters < ActiveRecord::Migration[5.2]
  def up
    add_column :parameters, :organization_id, :integer
    add_column :parameters, :location_id, :integer

    add_index :parameters, [:type, :organization_id, :location_id]
    add_index :parameters, [:type, :location_id]
  end

  def down
    remove_column :parameters, :organization_id
    remove_column :parameters, :location_id
  end
end
