class SimplifyParameters < ActiveRecord::Migration[4.2]
  def up
    remove_index  :parameters, [:host_id,      :type] if index_exists? :parameters, :host_id
    remove_index  :parameters, [:hostgroup_id, :type] if index_exists? :parameters, :hostgroup_id
    remove_index  :parameters, [:domain_id,    :type] if index_exists? :parameters, :domain_id

    rename_column :parameters, :host_id, :reference_id if column_exists? :parameters, :host_id
    add_index     :parameters, [:reference_id, :type] if index_exists? :parameters, :reference_id

    remove_column :parameters, :hostgroup_id if column_exists? :parameters, :hostgroup_id
    remove_column :parameters, :domain_id    if column_exists? :parameters, :domain_id
  end

  def down
    remove_index :parameters, [:reference_id, :type]

    add_column    :parameters, :domain_id,    :integer
    add_column    :parameters, :hostgroup_id, :integer
    rename_column :parameters, :reference_id, :host_id

    add_index :parameters, [:host_id, :type]
    add_index :parameters, [:hostgroup_id, :type]
    add_index :parameters, [:domain_id, :type]
  end
end
