class CreateComputeAttributes < ActiveRecord::Migration[4.2]
  def change
    create_table :compute_attributes do |t|
      t.integer :compute_profile_id
      t.integer :compute_resource_id
      t.string :name, :limit => 255
      t.text :vm_attrs

      t.timestamps null: true
    end

    add_index :compute_attributes, :compute_profile_id
    add_index :compute_attributes, :compute_resource_id

    add_foreign_key "compute_attributes", "compute_resources", :name => "compute_attributes_compute_resource_id_fk"
    add_foreign_key "compute_attributes", "compute_profiles", :name => "compute_attributes_compute_profile_id_fk"
  end
end
