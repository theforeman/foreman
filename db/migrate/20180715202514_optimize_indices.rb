class OptimizeIndices < ActiveRecord::Migration[5.1]
  def change
    # Primary key, no need to index again
    remove_index :audits, :id
    # duplicate index of "associated_index"
    remove_index :audits, name: "auditable_parent_index"
    # change order (polymorphic relation)
    remove_index :audits, name: "associated_index"
    add_index :audits, [:associated_type, :associated_id]
    # change order (polymorphic relation)
    remove_index :audits, name: "auditable_index"
    add_index :audits, [:auditable_type, :auditable_id, :version]
    # change order (polymorphic relation)
    remove_index :audits, [:user_id, :user_type]
    add_index :audits, [:user_type, :user_id]

    # change order (polymorphic relation)
    remove_index :bookmarks, [:owner_id, :owner_type]
    add_index :bookmarks, [:owner_type, :owner_id]

    # covered by [:ancestry, :names]
    remove_index :fact_names, :ancestry

    # covered by [:fact_name_id, :host_id]
    remove_index :fact_values, :fact_name_id

    # covered by [:type, :organization_id] and [:type, :location_id]
    remove_index :hosts, :type

    # may be a leftover from when priority was changed to match
    remove_index :lookup_values, name: "index_lookup_values_on_priority" if index_name_exists?(:lookup_values, "index_lookup_values_on_priority")

    # covered by [:type, :id]
    remove_index :nics, name: "index_by_type"

    # covered by [:user_id, :notification_id]
    remove_index :notification_recipients, :user_id

    # These may be leftover from an old migration (20100525094200_simplify_parameters.rb)
    remove_index :parameters, name: "index_parameters_on_domain_id_and_type" if index_name_exists?(:parameters, "index_parameters_on_domain_id_and_type")
    remove_index :parameters, name: "index_parameters_on_hostgroup_id_and_type" if index_name_exists?(:parameters, "index_parameters_on_hostgroup_id_and_type")
    remove_index :parameters, name: "index_parameters_on_host_id_and_type" if index_name_exists?(:parameters, "index_parameters_on_host_id_and_type")
    # Useless index, covered by [:type, :reference_id, :name] (no sense looking for reference_id with no type)
    remove_index :parameters, [:reference_id, :type] if index_exists?(:parameters, [:reference_id, :type])
    # covered by [:type, :reference_id, :name]
    remove_index :parameters, :type

    # covered by [:name, :resource_type]
    remove_index :permissions, :name

    # covered by [:host_id, :type, :id]
    remove_index :reports, :host_id
    # covered by [:type, :host_id]
    remove_index :reports, :type
    # covered by [:reported_at, :host_id, :type]
    remove_index :reports, :reported_at
    remove_index :reports, [:reported_at, :host_id]

    # covered by "taxable_index"
    remove_index :taxable_taxonomies, [:taxable_id, :taxable_type]
    # change order (polymorphic relation)
    remove_index :taxable_taxonomies, name: "taxable_index"
    add_index :taxable_taxonomies, [:taxable_type, :taxable_id, :taxonomy_id], name: "taxable_index", unique: true

    # covered by [:owner_type, :owner_id]
    remove_index :user_roles, :owner_type
    # change order (polymorphic relation)
    remove_index :user_roles, [:owner_id, :owner_type]
    add_index :user_roles, [:owner_type, :owner_id]
  end
end
